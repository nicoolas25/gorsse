# Gorsse (Go Ruby SSE)

This is the connection handler for the Gorsse project.

Since this project is only a dependency of the other, you should get the
general information from Gorsse instead of here.

## Build

The project try to respect the recommandations of the Go community.

My workflow is to make a `go install github.com/nicoolas25/gorsse/gorsse_server`.
and get the distribuable binary from `$GOPATH/bin/gorsse_server`.

## Install

Just make the binary available from your `$PATH`.

If Go is already setup, try this:

    go get github.com/nicoolas25/gorsse/gorsse_server
    $GOPATH/bin/gorsse_server

## Usage

There is only 3 options:

* `-c="tcp://127.0.0.1:4567" the address to send the callbacks`
* `-e="tcp://127.0.0.1:4568" the address to receive the events`
* `-p=8080                   the port to listen client connections`

## Dependencies

You should have the ZeroMQ library available on the host.
