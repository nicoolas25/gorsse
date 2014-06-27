module Gorsse
  class Client
    attr_reader :uid

    def initialize(uid)
      @uid = uid
    end

    def eql?(other)
      other.is_a?(Client) && uid == other.uid
    end
  end
end
