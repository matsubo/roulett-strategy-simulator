module Roulette
  module Simulator
    module Decisions
      class RandomColorDecision
        def initialize(table = nil)
          @table = table
        end

        # @params Bet
        # @return Bet
        def calculate(bet)
          bet_price = 1
          bet.color([Roulette::Simulator::Table::RED, Roulette::Simulator::Table::BLACK].sample, bet_price)
          bet
        end
      end
    end
  end
end
