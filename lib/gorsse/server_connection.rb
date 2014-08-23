require 'socket'
require 'thread'

module Gorsse
  class ServerConnection < Connection
    attr_reader :queue

    def initialize(url)
      @url = url
      @server = TCPServer.new(uri.host, uri.port)
      @queue = Queue.new
      @threads = []
    end

    def receive
      listen and @queue.pop
    end

    def close
      @thread.kill
      @threads.each(&:stop)
    end

    private

    def listen
      @thread ||= Thread.start do
        loop do
          @threads << ServerThread.new(@server.accept, self)
        end
      end
    end

    class ServerThread
      def initialize(tcpsocket, connection)
        @tcpsocket = tcpsocket
        @connection = connection
        @thread = loop!
      end

      def stop
        @thread.kill
        @tcpsocket.close
      end

      private

      def loop!
        Thread.start do
          loop do
            header = @tcpsocket.recv(10)
            length = header.to_i
            message = @tcpsocket.recv(length)
            @connection.queue << message
          end
        end
      end
    end
  end
end
