package master

import (
	"encoding/json"
	"fmt"

	es "github.com/nicoolas25/gorsse/gorsse_server/event"
	zmq "github.com/pebbe/zmq4"
)

type Callback struct {
	Protocol es.Protocol
	Scope    es.Scope
	Client   es.ClientId
	Callback string
}

type Client struct {
	Context  *zmq.Context
	Url      string
	quit     chan bool
	Commands chan Callback
	socket   *zmq.Socket
}

func NewClient(context *zmq.Context, url string) *Client {
	return &Client{
		Context:  context,
		Url:      url,
		Commands: make(chan Callback),
		quit:     make(chan bool),
	}
}

func (client *Client) Start() {
	client.connect()
	client.stream()
}

func (client *Client) Stop() {
	client.quit <- true
	client.socket.Close()
	fmt.Print("Terminating the client server.\n")
}

func (client *Client) connect() error {
	var err error
	client.socket, err = client.Context.NewSocket(zmq.PUSH)
	if nil == err {
		err = client.socket.Connect(client.Url)
	}
	return err
}

func (client *Client) stream() {
	var callback Callback
	var bytes []byte
	var err error

	for {
		select {
		case <-client.quit:
			break
		case callback = <-client.Commands:
			bytes, err = json.Marshal(callback)
			if nil == err {
				_, err = client.socket.SendBytes(bytes, 0)
				if nil != err {
					fmt.Printf("Message %s can't be send: %s\n", callback, err.Error())
				}
			} else {
				fmt.Printf("The callback %s can't be marshaled: %s\n", callback, err.Error())
			}
		}
	}
}
