require_relative "lib/Exchange.rb"

class Caterpiebot
    def initialize(environment)
        @setting = environment
        @fair_prices = Hash.new{|hash, key| hash[key] = Hash.new}
        @order_id_tracker = 1
        @purchase_limit = 10000000
        @single_limit = 10000
        @current_buyorders = 0
        @iterations = 1
    end

    def run
        @ex = Exchange.connect(@setting)

        #Wait until exchange is open
        while !@ex.open? do
            sleep(2)
        end
        loop do
                puts "new loop"
                sleep(2)
                @data = @ex.getDetails()
                @fulfilled_orders = @ex.getFulfilledOrders()
                find_fair_value()
                sell_existing_orders()
                buy_new_orders()
                @iterations++
                sleep(2)
        end
    end

    def find_fair_value()
        @data.each do | symbol_name, symbol |
            if !symbol[:buy_price] or !symbol[:sell_price]
                puts "No buy price"
                next
            end
            if !symbol[:fair_value] then
                symbol[:fair_value] = (symbol[:buy_price] + symbol[:sell_price]) / 2
            end
            symbol[:fair_value] += ((symbol[:buy_price] + symbol[:sell_price] / 2)/symbol[:fair_value])/@iterations

            if symbol[:fair_value] <= symbol[:sell_price]
                symbol[:should_sell] = true
                symbol[:should_buy] = false
            else
                symbol[:should_buy] = true
                symbol[:should_sell] = false
            end

            if rand(8) < 5 then
                symbol[:should_sell] = true
            end
        end
    end

    def sell_existing_orders
        @data.each do |symbol_name, symbol|
            if !symbol[:should_sell] then
                next
            end
            if symbol[:open] then
                r = Hash.new
                r[:type] = "add"
                r[:dir] = "SELL"
                r[:symbol] = symbol_name
                r[:size] = symbol[:sell_available]
                r[:price] = symbol[:sell_price]
                r[:order_id] = @order_id_tracker
                @order_id_tracker += 1

                if (@current_buyorders >= @purchase_limit)
                    next
                end

                while @single_limit < r[:size]*r[:price]
                    r[:size] -= 1
                end
                if (@ex.addOrderC(r)) then
                    @current_buyorders -= r[:size]*r[:price]
                    puts "sell" + "#{r}"
                end
            end
        end
        @fulfilled_orders.each do |order_id, order|
            if !@data[order[:symbol]][:should_sell] then
                next
            end
            if @data[order[:symbol]][:open] and order[:size] > 0 then
                r = Hash.new
                r[:type] = "add"
                r[:dir] = "SELL"
                r[:symbol] = order[:symbol]
                r[:price] = @data[order[:symbol]][:sell_price] - 1
                r[:size] = [@data[order[:symbol]][:sell_available], order[:size]].min
                r[:order_id] = @order_id_tracker
                @order_id_tracker += 1

                if (@ex.addOrderC(r)) then
                    @current_buyorders -= r[:size]*r[:price]
                    puts "sell" + "#{r}"
                end
            end
        end
    end

    def buy_new_orders
        @data.each do |symbol_name, symbol|
            if symbol == "XLF"
                next
            end
            if !symbol[:buy_price]
                puts "No buy price"
                next
            end
            if !symbol[:should_buy] then
                next
            end

            p symbol
            if symbol[:open] then
                r = Hash.new
                r[:type] = "add"
                r[:dir] = "BUY"
                r[:symbol] = symbol_name
                r[:size] = symbol[:buy_available]
                r[:price] = symbol[:buy_price]
                r[:order_id] = @order_id_tracker
                @order_id_tracker += 1

                if (@current_buyorders >= @purchase_limit)
                    next
                end

                while @single_limit < r[:size]*r[:price]
                    r[:size] -= 1
                end
                if (@ex.addOrderC(r)) then
                    @current_buyorders += r[:size]*r[:price]
                    puts "buy" + "#{r}"
                end
            end
        end
    end
end
