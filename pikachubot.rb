require_relative 'lib/Exchange.rb'

# starter bot
class PikachuBot
	def initialize(agent)
		#@fair_value = {}
		@current_value = {}
		@agent = agent
		@buyordercounter = 0
		@counter = 0
	end


	def log(output)
		#File.open('s.out', 'w') do |f|
			puts output
		#end
	end
	
	def update_fair_values

		# get the highest buying price for each security
		log(get_fulfilled_buy_orders)
		log(get_fulfilled_sell_orders)
		@buy_book = {}
		@sell_book = {}
		@order_book = @agent.getDetails
		@order_book.each do |sec, stats|
			@buy_book[sec] = stats[:buy_price]
			@sell_book[sec] = stats[:sell_price]
		end

		if @buy_book.nil? or @sell_book.nil?
			log("nilbook")
			return
		end

		# populate fair values with the means
		#common_securities = @buy_book.keys & @sell_book.keys
		#common_securities.each do |sec|
		#	@fair_value[sec] = [@buy_book[sec], @sell_book[sec]].reduce(:+).to_f / 2
		#end
	end

	def get_fulfilled_buy_orders
		temp = @agent.getFulfilledOrders
		new = {}
		temp.each do |k|
			new[k] = temp[k] if temp[k][:dir] == "BUY"
		end
		log("bought amount #{new.size}")
		new
	end

	def get_fulfilled_sell_orders
		temp = @agent.getFulfilledOrders
		new = {}
		temp.each do |k|
			new[k] = temp[k] if temp[k][:dir] == "SELL"
		end
		log("sold amount #{new.size}")
		new
	end

	def recommended_buy_order
		@top_10 = percentage_difference
		if @top_10.empty?
			return
		end
		@top_10.each_with_index do |sec, index|
		#every sec return 'buy, sec, (sell price - 1), 100/(index+1)'
			order = {type: "add", order_id: @counter, symbol: sec, dir: "BUY", price: @sell_book[sec]+1,
					 size: 100/(index + 1)}
			log(order)
			@buyordercounter += 1
			@agent.addOrder(order) if @buyordercounter < 10
		end
	end

	def recommended_sell_order
		@gottensecs = get_fulfilled_buy_orders
		@gottensecs.each do |id|
			order = {type: "add", order_id: @counter, symbol: @gottensecs[id][:sec], dir: "SELL", price: @buy_book[@gottensecs[:sec]]-1,
				 	size: @gottensecs[id][:size]}
			log(order)
			@buyordercounter = [0, @buyordercounter - 1].max
			@counter += 1
			@agent.addOrder(order)
		end
	end

	def percentage_difference
		@order_book = @agent.getDetails
		@percentages = {}
		if @order_book.nil?
			log("orderbook nil")
			return []
		end
		log("orderbook not nil")
		log(@order_book)
		@order_book.each do |key, val|
			log("checking for nil in oder_book")
			if val[:sell_price].nil? or val[:buy_price].nil?
				log("nil in oder_book")
				return []
			end
			@percentages[key] = val[:sell_price].to_f / val[:buy_price]
			log("#{key} percentage: #{@percentages[key]}")
			log("#{key} : sell #{val[:sell_price]} buy #{val[:buy_price]}")
		end
		log(@percentages.to_a)
		#temp = @percentages.to_a.sort_by { |a, b| b[1] <=> a[1] }.map { |x| x.first }.first(3)
		temp = @percentages.sort_by { |a, b| b }.reverse
		temp.delete("XLF")
		temp = temp.to_a.first(3).map { |x| x[0] }
		log("logging temp")
		log(temp)
		temp
	end

end

