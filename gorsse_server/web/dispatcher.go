package web_server

import (
	"sync"

	"github.com/nicoolas25/gorsse/gorsse_server/event"
)

type Dispatcher struct {
	lock  sync.Mutex
	Links map[event.Protocol]map[event.Scope]map[event.ClientId]*Link
}

func NewDispatcher() *Dispatcher {
	return &Dispatcher{
		Links: make(map[event.Protocol]map[event.Scope]map[event.ClientId]*Link),
		lock:  sync.Mutex{},
	}
}

func (dispatcher *Dispatcher) Unregister(link *Link) {
	// Lock the code that remove from the dispatcher an existing link
	dispatcher.lock.Lock()

	if scopes, ok := dispatcher.Links[link.protocol]; ok {
		if clients, ok := scopes[link.scope]; ok {
			if link, ok := clients[link.client]; ok {
				delete(clients, link.client)
				if 0 == len(clients) {
					delete(scopes, link.scope)
					if 0 == len(scopes) {
						delete(dispatcher.Links, link.protocol)
					}
				}
			}
		}
	}

	dispatcher.lock.Unlock()
}

func (dispatcher *Dispatcher) Register(proto event.Protocol, scope event.Scope, client event.ClientId) *Link {
	link := &Link{
		Events:   make(chan event.Event),
		protocol: proto,
		scope:    scope,
		client:   client,
	}

	// Lock the code that insert into the dispatcher the new link
	dispatcher.lock.Lock()

	if _, ok := dispatcher.Links[proto]; !ok {
		dispatcher.Links[proto] = make(map[event.Scope]map[event.ClientId]*Link)
	}

	if _, ok := dispatcher.Links[proto][scope]; !ok {
		dispatcher.Links[proto][scope] = make(map[event.ClientId]*Link)
	}

	dispatcher.Links[proto][scope][client] = link

	dispatcher.lock.Unlock()

	return link
}

func (dispatcher *Dispatcher) Dispatch(event event.Event) {
	if scopes, ok := dispatcher.Links[event.Protocol]; ok {
		if clients, ok := scopes[event.Scope]; ok {
			if "all" == event.Client {
				// Broadcast
				for _, link := range clients {
					link.Events <- event
				}
			} else {
				// Send to only one client
				if link, ok := clients[event.Client]; ok {
					link.Events <- event
				}
			}
		}
	}
}
