module Gorsse
  {
    :Client     => 'client',
    :Command    => 'command',
    :Config     => 'config',
    :Connection => 'connection',
    :Event      => 'event',
    :Protocol   => 'protocol',
    :VERSION    => 'version',
  }.each { |mod, file| autoload mod, "gorsse/#{file}" }

  def self.configure(&block)
    block.call(config)
  end

  def self.config
    @config ||= Config.new
  end

  def self.close_connections
    @conn && @conn.close
    @receiver_conn && @receiver_conn.close
  end

  def self.conn
    @conn ||= Connection.client(config.event_handler_url)
  end

  def self.receiver_conn
    @receiver_conn ||= Connection.server(config.callback_receiver_url)
  end

  def self.start_receiver_loop!
    loop do
      message = receiver_conn.receive
      command = Command.new(message)
      command.run!
    end
  end
end
