# require_relative 'lib/Exchange.rb'

# starter bot
class PikachuBot
	def initialize(agent)
		@fair_value = {}
		@current_value = {}
		@agent = agent
	end

	def update_fair_values
		order_book = @agent.get_order_book.buys
		highest_bids = {}
		lowest_offers = {}
		order_book.each do |buy|
			if highest_bids.has_key? buy.name
				highest_bids[buy.name] = buy.price if highest_bids[buy.name] < buy.price
			else
				highest_bids[buy.name] = buy.price
			end
		end
	end

	def recommended_order
	end
end

connection_type = "development_realistic"

agent = Exchange.connect(connection_type)

while !agent.open?
	sleep(1)
end

while agent.open?

	sleep(1)
end

agent.close()
