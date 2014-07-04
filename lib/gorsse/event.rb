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
        'proto' => sse_class_for(@protocol),
        'scope' => @protocol.scope,
        'client' => @target.kind_of?(Client) ? @target.uid : 'all',
      }

      if @entity.respond_to?(:to_sse)
        hash['title'] = sse_class_for(@entity)
        hash['content'] = @entity.to_sse
      else
        hash['title'] = @entity.to_s
        hash['content'] = ''
      end

      hash
    end

    def sse_class_for(instance)
      klass = instance.class
      klass.respond_to?(:sse_name) ? klass.sse_name : klass.name
    end
  end
end
