module Roulette
  module Simulator
    module Decisions
      class RandomSinglleDecision
        def initialize(table = nil)
          @table = table
        end

        # @params Bet
        # @return Bet
        def calculate(bet)
          bet_price = 1
          bet_number = rand(0..36)
          bet.single(bet_number, bet_price)
          bet
        end
      end
    end
  end
end
