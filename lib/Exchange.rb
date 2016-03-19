require 'json'
require 'socket'

require_relative "Constants.rb"

class Exchange
	def initialize (address, port)
		@connection = TCPSocket.new("#{address}", port)
		@open = false
	end

	def self.connect (server)
		if server == "development_realistic"
			exchange = Exchange.new(DEVELOPMENT_SERVER_ADDRESS, 25000)
		elsif server == "development_slow"
			exchange = Exchange.new(DEVELOPMENT_SERVER_ADDRESS, 25001)
		elsif server == "development_sandbox"
			exchange = Exchange.new(DEVELOPMENT_SERVER_ADDRESS, 25002)
		elsif server == "production"
			raise NotImplementedError, "sorry"
			# exchange = Exchange.new()
		else
			raise ArgumentError, "Argument 'server' must be either 'development_realistic', 'development_slow', 'development_sandbox', or 'production'"
		end
		return exchange
	end

	def open? ()
		if self.open
			return true
		else
			puts "sending hello"
			hello = JSON.parse('{
				"type": "hello",
				"team": "Dampier"
				}')
			@connection.puts hello
			puts @connection.gets
			return false
		end
	end

	def close ()
		@connection.close()
	end
end
