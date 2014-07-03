package event

import (
	"encoding/json"
	"fmt"

	zmq "github.com/pebbe/zmq4"
)

type Scope string
type Protocol string
type ClientId string

type Event struct {
	Protocol Protocol
	Scope    Scope
	Client   ClientId
	Event    string
	Data     string
}

type Server struct {
	Context *zmq.Context
	Url     string
	Events  chan Event
	quit    chan bool
	socket  *zmq.Socket
}

func NewServer(context *zmq.Context, url string) *Server {
	return &Server{
		Context: context,
		Url:     url,
		Events:  make(chan Event),
		quit:    make(chan bool),
	}
}

func (server *Server) Stop() {
	server.quit <- true
	server.socket.Close()
	fmt.Print("Terminating the event server.\n")
}

func (server *Server) Start() {
	server.connect()
	go server.stream()
	<-server.quit
}

func (server *Server) connect() error {
	var err error
	server.socket, err = server.Context.NewSocket(zmq.PULL)
	if nil == err {
		err = server.socket.Bind(server.Url)
	}
	return err
}

func (server *Server) stream() {
	var data map[string]interface{}

	for {
		message, err := server.socket.RecvBytes(0)

		if nil != err {
			fmt.Printf("RecvBytes failed: %s\n", err.Error())
			break
		}

		json.Unmarshal(message, &data)
		server.Events <- Event{
			Protocol: Protocol(data["proto"].(string)),
			Scope:    Scope(data["scope"].(string)),
			Client:   ClientId(data["client"].(string)),
			Event:    data["title"].(string),
			Data:     data["content"].(string),
		}
	}
}
