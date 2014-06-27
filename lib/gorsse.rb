require 'zmq'

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
    @control_conn && @control_conn.close
    Connection::ZCTX.close
  end

  def self.conn
    @conn ||= Connection.new(config.server, mode: :push, method: :connect)
  end

  def self.control_conn
    @control_conn ||= Connection.new(config.control, mode: :pull, method: :bind)
  end

  def self.start_control_loop!
    loop do
      message = control_conn.receive
      command = Command.new(message)
      command.run!
    end
  end
end
