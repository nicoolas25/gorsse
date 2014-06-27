require 'zmq'

module Gorsse
  # This class hide the ZMQ library but it is closely tied to it.
  class Connection
    ZCTX = ZMQ::Context.new(1)

    CONNECTION_MODE = {
      rep: ZMQ::REP,
      req: ZMQ::REQ,
      pub: ZMQ::PUB,
      sub: ZMQ::SUB,
      pull: ZMQ::PULL,
      push: ZMQ::PUSH,
    }

    # Open a connection to an URL. You can act as a server or as
    # a client by tunning the 'server' parameter.
    def initialize(url, mode: :push, method: :connect)
      @zmq_socket = ZCTX.socket(CONNECTION_MODE[mode])
      @zmq_socket.__send__(method, url)
    end

    def send(bytes, flags=0)
      @zmq_socket.send(bytes, flags)
    end

    def receive(flags=0)
      @zmq_socket.recv(flags)
    end

    def close
      @zmq_socket.close
    end
  end
end
