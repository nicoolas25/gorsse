#
# This is an example of a callback receiver program.
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'gorsse'

# Configure the library by defining the address to receive
# the external callback and the address to send the events.
Gorsse.configure do |config|
  config.receiver = 'tcp://127.0.0.1:4567'
  config.handler  = 'tcp://127.0.0.1:4568'
end

class Article < Struct.new(:title, :content)
  def to_sse
    '%s|%s' % [title, content]
  end
end

class BlogFeed < Gorsse::Protocol
  # After some client join a channel matching this protocol
  # this method is triggered. Custom signals can be sent to
  # all users or to the new one.
  def after_connect(client)
    super
    signal('welcome', target: client)
  end
end

trap('INT') do
  Gorsse.close_connections
  exit
end

Gorsse.start_control_loop!
