package web_server

import (
	"errors"
	"fmt"
	"net/http"
	"time"

	es "github.com/nicoolas25/gorsse/gorsse_server/event"
	mc "github.com/nicoolas25/gorsse/gorsse_server/master"
)

type Server struct {
	Url        string
	Dispatcher *Dispatcher
	events     chan es.Event
	commands   chan mc.Callback
	callbacks  bool
}

type Link struct {
	Events   chan es.Event
	protocol es.Protocol
	scope    es.Scope
	client   es.ClientId
	writer   *http.ResponseWriter
	request  *http.Request
}

func NewServer(port int, server *es.Server, client *mc.Client, callbacks bool) *Server {
	return &Server{
		Url:        fmt.Sprintf("0.0.0.0:%d", port),
		Dispatcher: NewDispatcher(),
		events:     server.Events,
		commands:   client.Commands,
		callbacks:  callbacks,
	}
}

func (server *Server) Start() {
	go server.startDispatcher()
	server.startServer()
}

func (server *Server) Stop() {
	// Nothing to do, the server will die as intended
}

func (server *Server) startDispatcher() {
	fmt.Print("Starting the dispatcher...\n")
	for {
		select {
		case event := <-server.events:
			server.Dispatcher.Dispatch(event)
		}
	}
}

func (server *Server) startServer() {
	fmt.Printf("Starting the server on %s...\n", server.Url)
	http.HandleFunc("/events", server.connectionHandler)
	http.ListenAndServe(server.Url, nil)
}

func (server *Server) register(w *http.ResponseWriter, r *http.Request) (*Link, error) {
	proto, scope, client := parseRequest(r)

	if "" == proto || "" == scope || "" == client {
		message := fmt.Sprintf("The request failed: <protocol:%s> <scope:%s> <client:%s>", proto, scope, client)
		return nil, errors.New(message)
	}

	link := server.Dispatcher.Register(proto, scope, client)
	link.writer = w
	link.request = r
	return link, nil
}

func (server *Server) unregister(link *Link) {
	server.Dispatcher.Unregister(link)
}

func (server *Server) afterConnect(link *Link) {
	if server.callbacks {
		server.commands <- mc.Callback{
			Protocol: link.protocol,
			Scope:    link.scope,
			Client:   link.client,
			Callback: "after_connect",
		}
	}
}

func (server *Server) sendEvent(w http.ResponseWriter, f http.Flusher, event es.Event) bool {
	_, err := fmt.Fprintf(w, "event: %s\n", event.Event)
	if nil != err {
		return false
	}
	if "" != event.Data {
		_, err = fmt.Fprintf(w, "data: %s\n", event.Data)
		if nil != err {
			return false
		}
	}
	_, err = fmt.Fprint(w, "\n")
	if nil != err {
		return false
	}
	f.Flush()
	return true
}

func (server *Server) connectionHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")

	link, err := server.register(&w, r)
	defer server.unregister(link)

	if nil != err {
		fmt.Fprintf(w, "%s\n", err.Error())
	} else {
		if f, ok := w.(http.Flusher); ok {
			server.afterConnect(link)
			for {
				select {
				case event := <-link.Events:
					if success := server.sendEvent(w, f, event); !success {
						break
					}
				}
			}
		} else {
			fmt.Fprint(w, "This connection doesn't support streaming.\n")
		}
	}
}

func parseRequest(r *http.Request) (es.Protocol, es.Scope, es.ClientId) {
	client := fmt.Sprintf("%x", time.Now().UnixNano())
	values := r.URL.Query()
	return es.Protocol(values.Get("p")), es.Scope(values.Get("s")), es.ClientId(client)
}
