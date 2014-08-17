require 'uri'

module Gorsse
  class Connection
    def self.client(url)
      ClientConnection.new(url)
    end

    def self.server(url)
      ServerConnection.new(url)
    end

    protected

    def uri
      @uri ||= URI.parse(@url)
    end
  end

  require_relative 'server_connection'
  require_relative 'client_connection'
end
