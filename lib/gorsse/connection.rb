require 'ffi-rzmq'

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
      puts '%s with %s to %s' % [method, mode, url]
    end

    def send(string, flags: 0)
      puts 'Sending: %s' % string
      @zmq_socket.send_string(string, flags)
    end

    def receive(flags: 0)
      message = ''
      @zmq_socket.recv_string(message, flags)
      message
    end

    def close
      @zmq_socket.close
    end
  end
end
