require_relative "lib/Exchange.rb"

class Caterpiebot
    def initialize(environment)
        @setting = environment

        @order_id_tracker = 1
        @purchase_limit = 200000
        @single_limit = 20000
        @current_buyorders = 0
    end

    def run
        @ex = Exchange.connect(@setting)

        #Wait until exchange is open
        while !@ex.open? do
            sleep(0.2)
        end
        loop do

                @data = @ex.getDetails()
                @fulfilled_orders = @ex.getFulfilledOrders()
                sell_existing_orders()
                buy_new_orders()
                puts "new loop"
                sleep(2)
        end
    end

    def new_order_id()

    end

    def sell_existing_orders
        @fulfilled_orders.each do |order_id, order|
            if !symbol[:sell_price]
                puts "No sell price"
                next
            end
            if @data[order[:symbol]][:open] and order[:size] > 0 then
                r = Hash.new
                r[:type] = "add"
                r[:dir] = "SELL"
                r[:symbol] = order[:symbol]
                r[:price] = @data[order[:symbol]][:sell_price]
                r[:size] = [@data[order[:symbol]][:sell_available], order[:size]].min
                r[:order_id] = @order_id_tracker
                @order_id_tracker += 1

                if (@ex.addOrder(r)) then
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
            p symbol
            if symbol[:open] then
                r = Hash.new
                r[:type] = "add"
                r[:dir] = "BUY"
                r[:symbol] = symbol_name
                r[:size] = symbol[:buy_available]
                r[:price] = symbol[:buy_price] + 1
                r[:order_id] = @order_id_tracker
                @order_id_tracker += 1
                while r[:size]*r[:price] > @single_limit  do
                    r[:size] -= 1
                    puts r[:size]
                    if r[:size] <= 0 then
                        next
                    end
                end
                p r
                if (@ex.addOrder(r)) then
                    @current_buyorders += r[:size]*r[:price]
                    puts "buy" + "#{r}"
                end
            end
        end
    end
end
