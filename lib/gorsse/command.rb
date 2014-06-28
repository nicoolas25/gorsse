require 'json'

module Gorsse
  class Command
    def initialize(command)
      @command = JSON.parse(command)
    end

    def run!
      protocol_class = Object.const_get(@command['Protocol'])
      protocol = protocol_class.new(@command['Scope'])
      client = Client.new(@command['Client'])
      protocol.__send__(@command['Callback'], client)
    end
  end
end
