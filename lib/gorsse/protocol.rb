module Gorsse
  class Protocol
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    # Send a message to the client through the Gorsse server.
    def signal(entity, target: :all)
      event = Event.new(self, target, entity)
      event.send!
    end

    def after_connect(client_id)
      # Do nothing. Override in subclasses.
    end

    def eql?(other)
      self.class == other.class && self.scope == other.scope
    end
  end
end
