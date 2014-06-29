# Gorsse (Go Ruby SSE)

This is an proof of concept for an SSE system that will support many
users without compromising a Ruby server that isn't that good to handle
a lot of alive connections.

The typical flow is:

1. The server povides an application
2. The client needs realtime informations from the server
3. The client establish a SSE connection to the application
4. The server send the informations via the SSE connection
5. The client is happy to have real-time updates

If your application get too many client, your server will have to handle
as much as connections. Since Ruby isn't very well suited for parallelism,
the existing webservers forks and/or threads the application to handle
multiple requests at a time. To serve two clients exactly at the same time,
you have to run two instances of your application. If those two client need
to keep the connection alive then your application is down to the rest of
the world...

This may be not the case on all the Ruby implementation and for all
webservers, see the alternative server for more details about it.

## Architecture

The whole idea is to keep your Ruby application as it is, adding one
or two other elements to your existing architecture.

### The connection handler

When you run the connection handler, it will accept HTTP requests and
stream the response to the client. It will maintain the connection to the
client open.

The connection handler will also listen events from your application. When
a such event is received, it is forwarded to the relevent clients.

The connection handler lives in a separate project. It's written in a
language that have a more advanced concurrency and parallelism model than
Ruby.

See the documentation of the connection handler to configure it.

### The callback receiver (optionnal)

This element receive callback from the connection handler. Those
callbacks can trigger business Ruby code depending on your needs.

If you don't need the callback receiver, you should disable them in
the connection handler configuration. In this case, you dont have to
run this component at all.

### Communication

ZeroMQ allows the communication between:

* your application, that send event to the connection handler,
* the connection handler, that receive those events via SSE and
* the callback receiver.

## Integration

This is probably the part that you've been waiting...

### Configuration

First of all, your application must require 'gorsse' and configure it
properly:

~~~
:::ruby
require 'gorsse'

Gorsse.configure do |config|
  config.receiver = 'tcp://127.0.0.1:4567'
  config.handler  = 'tcp://127.0.0.1:4568'
end
~~~

The addresses are directly passed to ZeroMQ, feel free to take advantage
of it.

The receiver line isn't required unless you use the callback receiver.

### Protocols & scopes

Gorsse is using two concepts to create SSE channels where it is possible
to publish informations.

*Protocols* match a specific communication pattern from your server to
your clients. This is an example of a two empty protocol:

~~~
:::ruby
class PostFeed < Gorsse::Protocol ; end
class ChatFeed < Gorsse::Protocol ; end
~~~

*Scopes* are like an instance of the protocol, it's narrowing it. For
instance, if your application is a blog provider SaaS then you'll have
one `PostFeed` scope per blog. Or, if your application is a chat server
then you'll have one `ChatFeed` scope per channel.

~~~
:::ruby
endpoint = ChatFeed.new('room42')
~~~

You can see the protocol and scope as an endpoint like `/ChatFeed/room42`.

### Sending events

From the previous example, you can publish a message to all the connected
clients with the following code:

~~~
:::ruby
class Message < Struct.new(:author, :content)
  # This is required to be send as an event by Gorsse.
  # @return String
  def to_sse
    "#{author}|#{content}"
  end
end

endpoint.signal Message.new('Nicolas', 'Hello!')
~~~

The previous code will generate the following lines in the SSE stream:

~~~
event: Message
data: Nicolas|Hello!

~~~

### Private messages

You can achieve private messages with scopes.

There is also a notion of Client.

*This section should be completed.*

## Alternative

There is many other solutions out there that are aiming the same goal.
You can try to fix the server with Goliath or you can rely on external
components with Faye.

I don't think webservers like Puma is a viable alternative even if it
is using threads to handle requests. I'll be glad to have your feedback
on it.

Of course all of this project is tied to the Ruby world. You can have
it all for free with other platforms like Meteor.

## Licence

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.