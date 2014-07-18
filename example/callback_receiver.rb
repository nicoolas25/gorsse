#
# This is an example of a callback receiver program.
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'json'
require 'gorsse'

# Configure the library by defining the address to receive
# the external callback and the address to send the events.
Gorsse.configure do |config|
  config.receiver = 'tcp://127.0.0.1:4567'
  config.handler  = 'tcp://127.0.0.1:4568'
end

# The Article is the entity to send via SSE
# and it only has to implement the #to_sse method.
class Article < Struct.new(:title, :content)
  def to_sse
    JSON.generate({title: title, content: content})
  end
end


# The CurentClient is another kind of entity.
class CurrentClient < Struct.new(:uid)
  # The name used for the event is the classname. With a
  # .sse_name classmethod, you can override this behaviour.
  def self.sse_name
    'current_client'
  end

  def to_sse
    JSON.generate({uid: uid})
  end
end

class BlogFeed < Gorsse::Protocol
  # After some client join a channel matching this protocol
  # this method is triggered. Custom signals can be sent to
  # all users or to the new one.
  #
  # In this cas we send to each client its current uid.
  def after_connect(client)
    super
    signal(CurrentClient.new(client.uid), target: client)
  end
end

trap('INT') do
  Gorsse.close_connections
  exit
end

Gorsse.start_receiver_loop!
