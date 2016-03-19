# require_relative 'lib/Exchange.rb'

class PikachuBotRunner
    def initialize(string)
        @agent = Exchange.connect(string)
        
    end

    def run
    end
end
