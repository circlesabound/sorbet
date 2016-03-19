require_relative "lib/Exchange.rb"
require_relative "lib/Request.rb"

loop do

    $setting = "development_realistic"
    $ex = Exchange.connect(setting)

    #Wait until exchange is open
    while !$ex.open? do
        sleep(0.1)
    end

    #Initialise fair value
    $fair_value = Hash.new
    #Initialise current orders
    $current_orders = Hash.new

    #Initialise
    while $ex.open? do
        $data = ex.getDetails()
        determine_fair_value()
        sell_existing_orders()
        buy_new_orders()

        sleep(40)
    end

    $ex.close()
    
    sleep(10)
end


def determine_fair_value
    $data.each do |key, item|
        #Doesn't do anything yet
    end
end

def sell_existing_orders
    $data.each do |key, item|
        r = Request.new
        r.type = "add"
        r.dir = "SELL"
        r.symbol = key
        r.size = 10
        r.price = item.sell_price - 1
    end
end

def buy_new_orders
    $data.each do |key, item|
        r = Request.new
        r.type = "add"
        r.dir = "BUY"
        r.symbol = key
        r.price = item.buy_price
        r.size = 10
        $ex.makeRequest(r)
    end
end
