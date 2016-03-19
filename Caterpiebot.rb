require_relative "lib/Exchange.rb"

class Caterpiebot
    def initialize(environment)
        @setting = environment

        @order_id_tracker = 1
    end

    def run
        loop do
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
                sleep(0.2)
            end
        end
    end

    def new_order_id()

    end

    def sell_existing_orders
        @fulfilled_orders.each do |order_id, order|

            if @data[order[:symbol]][:open] and order[:size] > 0 then
                r = Hash.new
                r[:type] = "add"
                r[:dir] = "SELL"
                r[:symbol] = order[:symbol]
                r[:price] = symbol[:sell_price]
                r[:size] = [symbol[:sell_available], order[:size]].min
                r[:order_id] = @order_id_tracker
                @order_id_tracker += 1
                if (@ex.addOrder(r)) then

                end
            end
        end
    end

    def buy_new_orders
        @data.each do |symbol_name, symbol|
            if symbol[:open] then
                r = Hash.new
                r[:type] = "add"
                r[:dir] = "BUY"
                r[:symbol] = symbol_name
                r[:size] = symbol[:buy_available]
                r[:price] = symbol[:buy_price]
                r[:order_id] = @order_id_tracker
                @order_id_tracker += 1
                if (@ex.addOrder(r)) then

                end
            end
        end
    end
end
