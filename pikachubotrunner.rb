require_relative 'lib/Exchange.rb'
require 'pikachubot.rb'

class PikachuBotRunner
	def initialize(string)
		@agent = Exchange.connect(string)
		
	end

	def run
		while not @agent.open?
			sleep(1)
		end
		pikachu = PikachuBot.new(@agent)
		while @agent.open?
			pikachu.update_fair_values
			pikachu.recommended_buy_order
			pikachu.recommended_sell_order
			sleep(5)
		end
		@agent.close
	end
end