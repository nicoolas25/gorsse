require 'json'

module Gorsse
  class Command
    def initialize(command)
      @command = JSON.parse(command)
    end

    def run!
      protocol_class = Object.const_get(@command['proto'])
      protocol = protocol_class.new(@command['scope'])
      client = Client.new(@command['client'])
      protocol.__send__(@command['callback'], client)
    end
  end
end
