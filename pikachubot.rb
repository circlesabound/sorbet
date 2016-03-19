# require_relative 'lib/Exchange.rb'

# starter bot
class PikachuBot
	def initialize(agent)
		@fair_value = {}
		@current_value = {}
		@agent = agent
	end

	def update_fair_values
		highest_bids = {}
		lowest_offers = {}

		# get the highest buying price for each security
		@order_book = @agent.get_order_book.buys
		@order_book.each do |buy|
			if highest_bids.has_key? buy.name
				highest_bids[buy.name] = buy.price if highest_bids[buy.name] < buy.price
			else
				highest_bids[buy.name] = buy.price
			end
		end

		# get the lowest selling price for each security
		@order_book = @agent.get_order_book.sells
		@order_book.each do |sell|
			if lowest_offers.has_key? sell.name
				lowest_offers[sell.name] = sell.price if lowest_offers[sell.name] > sell.price
			else
				lowest_offers[sell.name] = sell.price
			end
		end

		# populate fair values with the means
		common_securities = highest_bids.keys & lowest_offers.keys
		common_securities.each do |sec|
			@fair_value[sec] = [highest_bid[sec], lowest_offers[sec]].reduce(:+).to_f / 2
		end
	end

	def recommended_order
		@top_10 = percentage_difference
		@top_10.each_with_index do |sec, index|
		#every sec return 'buy, sec, (sell price - 1), 100/(index+1)'
		end
	end

	def percentage_difference
		@order_book.each do |key, val|
			@percentages[key] = val[1].to_f / val[0]
		end
		@percentages.to_a.sort_by { |a, b| b[1] <=> a[1] }.map { |x| x.first }.first(10)
	end

end

