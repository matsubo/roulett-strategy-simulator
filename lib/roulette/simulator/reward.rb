module Roulette
  module Simulator
    class Reward
      # @return [Hash{Symbol => Integer}] amount returned (stake included) per bet, keyed like BetData#stakes_by_bet
      def self.by_bet(bet_data, result)
        {
          single: bet_data.singles[result.number] * 36,
          color: bet_data.colors[result.color] * 2,
          lowhigh: bet_data.lowhighs[result.lowhigh] * 2,
          evenodd: bet_data.evenodds[result.evenodd] * 2,
          dozen: bet_data.dozens[result.dozen] * 3,
          column: bet_data.columns[result.column] * 3
        }
      end
    end
  end
end
