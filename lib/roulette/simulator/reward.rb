module Roulette
  module Simulator
    class Reward
      def self.calculate(bet_data, result)
        reward = 0

        # singles
        reward += (bet_data.singles[result.number] || 0) * 36

        # colors
        reward += (bet_data.colors[result.color] || 0) * 2

        # lowhighs
        reward += (bet_data.lowhighs[result.lowhigh] || 0) * 2

        # evenodd
        reward += (bet_data.evenodds[result.evenodd] || 0) * 2

        # dozens
        reward +=  (bet_data.dozens[result.dozen] || 0) * 3

        # columns
        reward += (bet_data.columns[result.column] || 0) * 3

        reward
      end
    end
  end
end
