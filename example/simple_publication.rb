#
# This is a simple example of using gorsse from a Ruby application.
# The callback receiver isn't used here.
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'json'
require 'gorsse'

# Configure the library by defining the address to receive
# the external callback and the address to send the events.
Gorsse.configure do |config|
  config.handler  = 'tcp://127.0.0.1:4568'
end

# Define an entity to use as an event.
# An entity should only have a to_sse method.
class Article < Struct.new(:title, :content)
  def to_sse
    JSON.generate({title: title, content: content})
  end
end

# Create an specific use case of communication. This is
# called a protocol in the library. Specific behaviours
# can be defined in the class, callbacks too.
class PostFeed < Gorsse::Protocol ; end

# Create a Protocol instance scoped with 'myblog'.
post_feed = PostFeed.new('myblog')

# Create an new event to send.
article = Article.new('Title', 'Content')

# Signal the post_feed listenners with the 'article',
# all the clients should receive the signal (it's the default).
post_feed.signal(article)

# Close the connexion when the program exits
at_exit do
  Gorsse.close_connections
end
