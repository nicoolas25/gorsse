package master

import (
	"encoding/json"
	"fmt"
	"net"

	es "github.com/nicoolas25/gorsse/gorsse_server/event"
)

type Callback struct {
	Protocol es.Protocol
	Scope    es.Scope
	Client   es.ClientId
	Callback string
}

type Client struct {
	Url      string
	quit     chan bool
	Commands chan Callback
	conn     net.Conn
}

func NewClient(url string) *Client {
	return &Client{
		Url:      url,
		Commands: make(chan Callback),
		quit:     make(chan bool),
	}
}

func (client *Client) Start() {
	client.stream()
}

func (client *Client) Stop() {
	client.quit <- true
	if client.conn != nil {
		client.conn.Close()
	}
	fmt.Print("Terminating the client server.\n")
}

func (client *Client) connect() (err error) {
	client.conn, err = net.Dial("tcp", client.Url)
	return
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
				if client.conn == nil {
					err = client.connect()
					if err != nil {
						fmt.Printf("Client connection error: %s\n", err.Error())
						break
					}
				}

				header := fmt.Sprintf("%10d", len(bytes))
				_, err = client.conn.Write([]byte(header))

				if nil != err {
					fmt.Printf("Message %s can't be send: %s\n", callback, err.Error())
				}

				_, err = client.conn.Write(bytes)

				if nil != err {
					fmt.Printf("Message %s can't be send: %s\n", callback, err.Error())
				}
			} else {
				fmt.Printf("The callback %s can't be marshaled: %s\n", callback, err.Error())
			}
		}
	}
}
