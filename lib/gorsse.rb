module Gorsse
  {
    :Client     => 'client',
    :Command    => 'command',
    :Config     => 'config',
    :Connection => 'connection',
    :Event      => 'event',
    :Protocol   => 'protocol',
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
    Connection::ZCTX.terminate
  end

  def self.conn
    @conn ||= Connection.new(config.handler, mode: :push, method: :connect)
  end

  def self.receiver_conn
    @receiver_conn ||= Connection.new(config.receiver, mode: :pull, method: :bind)
  end

  def self.start_receiver_loop!
    loop do
      message = receiver_conn.receive
      command = Command.new(message)
      command.run!
    end
  end
end
