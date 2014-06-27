require 'json'

module Gorsse
  class Event
    def initialize(protocol, target, entity)
      @protocol = protocol
      @target = target
      @entity = entity
    end

    def send!
      json = JSON.generate(msg)
      Gorsse.conn.send(json)
    end

    private

    def msg
      hash = {
        'protocol' => @protocol.class.name,
        'scope' => @protocol.scope,
        'target' => @target.kind_of?(Client) ? @target.uid : 'all',
      }

      if @entity.respond_to?(:to_sse)
        hash['title'] = @entity.class.name
        hash['content'] = @entity.to_sse
      else
        hash['title'] = @entity.to_s
        hash['content'] = nil
      end

      hash
    end
  end
end
