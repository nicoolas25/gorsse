require 'gorsse'

Gorsse.configure do |config|
  config.callback_receiver_url = 'http://127.0.0.1:4567'
  config.event_handler_url     = 'http://127.0.0.1:4568'
end

class FakeConnection ; end

RSpec.configure do |config|
  config.before(:example) do
    allow(Gorsse).to receive(:conn).and_return(FakeConnection.new)
  end
end
