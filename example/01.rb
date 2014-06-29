$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'gorsse'

# Configure the library by defining the address to receive
# the external callback and the address to send the events.
Gorsse.configure do |config|
  config.receiver = 'tcp://127.0.0.1:4567'
  config.handler  = 'tcp://127.0.0.1:4568'
end

# Define an entity to use as an event.
# An entity should only have a to_sse method.
class Article
  attr_accessor :title, :content

  def initialize(attributes={})
    attributes.each do |attr, value|
      self.__send__("#{attr}=", value)
    end
  end

  def to_sse
    '%s|%s' % [title, content]
  end
end

# Create an specific use case of communication. This is
# called a protocol in the library. Specific behaviours
# can be defined in the class.
class BlogFeed < Gorsse::Protocol
  # After some client join a channel matching this protocol
  # this method is triggered. Custom signals can be sent to
  # all users or to the new one.
  def after_connect(client)
    super
    signal('welcome', target: client)
  end
end

# Create a Protocol instance scoped with 'loremscope'.
loremblog = BlogFeed.new('loremblog')

# Create an new event to send.
article = Article.new(title: 'Title', content: 'Content')

# Signal the loremblog listenners with the 'article',
# all the clients should receive the signal (it's the default).
loremblog.signal(article, target: :all)

trap('INT') do
  puts 'stopping gorsse'
  Gorsse.close_connections
  exit
end

# Gorsse.start_control_loop!
