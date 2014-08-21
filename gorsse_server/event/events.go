package event

import (
	"encoding/json"
	"fmt"
	"net"
	"strconv"
	"strings"
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
	Url      string
	Events   chan Event
	quit     chan bool
	listener net.Listener
}

func NewServer(url string) *Server {
	return &Server{
		Url:    url,
		Events: make(chan Event),
		quit:   make(chan bool),
	}
}

func (server *Server) Stop() {
	server.quit <- true
	server.listener.Close()
	fmt.Print("Terminating the event server.\n")
}

func (server *Server) Start() {
	go server.stream()
	<-server.quit
}

func (server *Server) stream() {
	listener, err := net.Listen("tcp", server.Url)

	if err != nil {
		fmt.Printf("Server event: failed to listen to the Url: %s\n", err.Error())
		return
	}

	server.listener = listener

	for {
		conn, err := server.listener.Accept()

		if err != nil {
			fmt.Printf("Server event: failed to accept a connection: %s\n", err.Error())
			continue
		}

		go server.handleConn(conn)
	}
}

func (server *Server) handleConn(conn net.Conn) {
	defer conn.Close()

Loop:
	for {
		var header [10]byte
		headerSize, err := conn.Read(header[0:])

		if headerSize != 10 {
			fmt.Print("Server event: read size failed: not enough byte read\n")
			break
		}

		if err != nil {
			fmt.Printf("Server event: read size failed: %s\n", err.Error())
			break
		}

		size, err := strconv.ParseInt(strings.TrimSpace(string(header[:])), 10, 8)

		if err != nil {
			fmt.Printf("Server event: malformed header: %s\n", err.Error())
			break
		}

		if size <= 0 {
			fmt.Print("Server event: malformed header: size must be positive\n", err.Error())
			break
		}

		message := make([]byte, size, size)
		cursor := 0

		for {
			read, err := conn.Read(message[cursor:])
			cursor = cursor + read

			if err != nil {
				fmt.Printf("Server event: read event failed: %s\n", err.Error())
				break Loop
			}

			if cursor >= int(size) {
				break
			}
		}

		var data map[string]interface{}
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
