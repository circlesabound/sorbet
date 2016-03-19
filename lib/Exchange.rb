require 'json'
require 'socket'

require_relative "Constants.rb"

class Exchange
	def initialize (address, port)
		@connection = TCPSocket.new("#{address}", port)
		@open = false
		@prices = Hash.new { |hash, key| hash[key] = Hash.new }
		@rawMessageQueue = Queue.new()
		@messageQueue = Queue.new()
		@threads = Hash.new()
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
		else
			raise ArgumentError, "Argument 'server' must be either 'development_realistic', 'development_slow', 'development_sandbox', or 'production'"
		end
		return exchange
	end

	def initThreads ()
		@threads[:MessageGetter] = Thread.new do
			while message = @connection.gets
				@rawMessageQueue << JSON.parse(message)
			end
		end
		@threads[:MessageReader] = Thread.new do
			while message = @rawMessageQueue.pop
				if message["type"] == "book" or message["type"] == "trade"
					self.updatePrices(message)
				elsif message["type"] == "open" or message["type"] == "close"
					self.openCloseSymbol(message)
				else
					@messageQueue << message
				end
			end
		end
	end

	def getDetails ()
		return @prices
	end

	def updatePrices (bookMessage)
		symbol = bookMessage["symbol"]
		@prices[symbol][:buy_price] = bookMessage["buy"][0][0]
		@prices[symbol][:buy_quantity] = bookMessage["buy"][0][1]
		@prices[symbol][:sell_price] = bookMessage["sell"][0][0]
		@prices[symbol][:sell_quantity] = bookMessage["sell"][0][1]
	end

	def openCloseSymbol (bookMessage)
		bookMessage["symbols"].each do |symbol|
			if bookMessage["type"] = "open"
				@prices[symbol][:open] = true
			elsif bookMessage["type"] = "close"
				@prices[symbol][:open] = false
			end
		end
	end

	def open? ()
		if @open
			return true
		else
			puts "sending hello"
			hello = {
				"type": "hello",
				"team": "DAMPIER"
				}.to_json
			@connection.puts hello
			if JSON.parse(@connection.gets)["type"] == "hello"
				self.initThreads()
				return true
			end
		end
	end

	def close ()
		@threads.each do |thread|
			thread.kill
		end
		@connection.close()
	end
end
