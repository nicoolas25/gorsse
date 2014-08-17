require 'socket'

module Gorsse
  class ClientConnection < Connection
    attr_reader :queue

    def initialize(url)
      @url = url
      @tcpsocket = TCPSocket.new(uri.host, uri.port)
    end

    def send(message)
      length = message.length
      header = '%10i' % length
      @tcpsocket.sendmsg(header + message)
    end

    def close
      @tcpsocket.close
    end
  end
end
