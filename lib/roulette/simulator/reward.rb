module Roulette
  module Simulator
    class Reward
      def self.calculate(bet, result)
        reward = 0

        # singles
        reward += begin
          bet.singles[result.number] * 36
        rescue StandardError
          0
        end

        # colors
        reward += begin
          bet.colors[result.color] * 2
        rescue StandardError
          0
        end

        # lowhighs
        reward += begin
          bet.lowhighs[result.lowhigh] * 2
        rescue StandardError
          0
        end

        # dozens
        reward += begin
          bet.dozens[result.dozen] * 3
        rescue StandardError
          0
        end

        # columns
        reward += begin
            bet.columns[result.column] * 3
          rescue StandardError
            0
          end

        reward
      end
    end
  end
end
