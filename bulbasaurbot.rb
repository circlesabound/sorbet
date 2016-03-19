require_relative "lib/Exchange.rb"

class Bulbasaurbot
	def initialize(str)
		@exchange = Exchange.connect(str)
		@order_id = 0
		@old_prices = nil
		@new_prices = nil
	end

	def get_order_id ()
		@order_id += 1
		return @order_id
	end

	def run ()
		while !@exchange.open? do
			sleep(0.2)
		end

		# wait a bit to get data
		sleep(2)
		update_prices()
		sleep(2)

		loop do
			update_prices()

			suggestions = what_to_do()

			suggestions.each do |symbol, hash|
				if hash[:buy]
					puts "Buy #{hash[:buy_quantity]} of #{symbol}"
					request = {
						"order_id": get_order_id(),
						"symbol": symbol,
						"dir": "BUY",
						"size": hash[:buy_quantity]
					}
					@exchange.addOrderC(request)
				end
				if hash[:sell]
					puts "Sell #{hash[:sell_quantity]} of #{symbol}"
					request = {
						"order_id": get_order_id(),
						"symbol": symbol,
						"dir": "SELL",
						"size": hash[:sell_quantity]
					}
					@exchange.addOrderC(request)
				end
			end

			sleep(0.5)
		end
	end

	def what_to_do ()
		suggestions = Hash.new()
		if @old_prices.nil? or @new_prices.nil?
			# skip
			return nil
		else
			@old_prices.each do |symbol, p|
				if @new_prices[symbol][:buy_price] < @old_prices[symbol][:buy_price]
					suggestions[symbol][:buy] = true
					suggestions[symbol][:buy_quantity] = [@new_prices[symbol][:buy_available] - 1, 0].max
				else
					suggestions[symbol][:buy] = false
				end
				if @new_prices[symbol][:sell_price] > @old_prices[symbol][:sell_price]
					suggestions[symbol][:sell] = true
					suggestions[symbol][:sell_quantity] = [@new_prices[symbol][:sell_available] - 1, 0].max
				else
					suggestions[symbol][:sell] = false
				end
			end
		end
	end

	def update_prices ()
		@old_prices = @new_prices
		@new_prices = @exchange.getDetails()
	end
end
