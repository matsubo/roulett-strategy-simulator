module Roulette
  module Simulator
    class BetData
      attr_reader :singles, :colors, :dozens, :columns, :lowhighs, :evenodds

      def initialize
        @singles = Hash.new(0)
        @colors = Hash.new(0)
        @dozens = Hash.new(0)
        @columns = Hash.new(0)
        @lowhighs = Hash.new(0)
        @evenodds = Hash.new(0)
      end

      def single(number, bet)
        @singles[number] += bet
      end

      def color(color, bet)
        @colors[color] += bet
      end

      def dozen(dozen, bet)
        @dozens[dozen] = bet
      end

      def column(column, bet)
        @columns[column] = bet
      end

      def lowhigh(lowhigh, bet)
        @lowhighs[lowhigh] = bet
      end
      def evenodd(evenodd, bet)
        @evenodds[evenodd] = bet
      end

      def sum
        @singles.values.sum + @colors.values.sum + @dozens.values.sum + @columns.values.sum + @lowhighs.values.sum + @evenodds.values.sum
      end
    end
  end
end
