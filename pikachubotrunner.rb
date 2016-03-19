require_relative 'lib/Exchange.rb'
require_relative 'pikachubot.rb'

class PikachuBotRunner
	def initialize(string)
		@agent = Exchange.connect(string)
		
	end

	def run
		pikachu = PikachuBot.new(@agent)
		while @agent.open?
		end
		loop do
			pikachu.log("looping")
			pikachu.update_fair_values
			pikachu.recommended_buy_order
			pikachu.recommended_sell_order
			sleep(0.1)
		end
	end
end
