package main

import (
	"flag"
	"os"
	"os/signal"

	es "github.com/nicoolas25/gorsse/gorsse_server/event"
	mc "github.com/nicoolas25/gorsse/gorsse_server/master"
	ws "github.com/nicoolas25/gorsse/gorsse_server/web"
)

func main() {
	// Declare the flags of the server
	events_url := flag.String("e", "127.0.0.1:4568", "the address to receive the events")
	master_url := flag.String("c", "127.0.0.1:4567", "the address to send the callbacks")
	port := flag.Int("p", 8080, "the port to listen client connections")
	callback := flag.Bool("s", false, "turn on the callbacks when present")
	flag.Parse()

	// Launch the event server
	es_server := es.NewServer(*events_url)
	go es_server.Start()
	defer es_server.Stop()

	// Create a master client
	mc_client := mc.NewClient(*master_url)
	go mc_client.Start()
	defer mc_client.Stop()

	// Handle the CTRL + C
	abort := make(chan os.Signal, 1)
	signal.Notify(abort, os.Interrupt)

	// Create the web server
	ws_server := ws.NewServer(*port, es_server, mc_client, *callback)
	go ws_server.Start()
	defer ws_server.Stop()

	<-abort
}
