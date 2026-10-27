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

      # Adds a stake on one side of an outside bet.
      def place(outside_bet, side, stake)
        outside_stakes.fetch(outside_bet.name)[side] += stake
      end

      # @return [Hash{Symbol => Integer}] total stake per bet, keyed like Reward.by_bet
      def stakes_by_bet
        { single: @singles.values.sum }.merge(outside_stakes.transform_values { |stakes| stakes.values.sum })
      end

      def sum
        stakes_by_bet.values.sum
      end

      private

      def outside_stakes
        { color: @colors, lowhigh: @lowhighs, evenodd: @evenodds, dozen: @dozens, column: @columns }
      end
    end
  end
end
