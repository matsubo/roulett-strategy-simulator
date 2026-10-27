require_relative 'table'

module Roulette
  module Simulator
    # A bet on a group of numbers on the European wheel; zero lands on no side.
    class OutsideBet
      attr_reader :name, :payout, :sides

      # @param sides [Hash{Integer => Enumerable<Integer>}] side => numbers that land on it
      def initialize(name, payout:, sides:)
        @name = name
        @payout = payout
        @sides = sides.keys.freeze
        @side_by_number = sides.flat_map { |side, numbers| numbers.map { |number| [number, side] } }.to_h.freeze
      end

      # @return [Integer, nil] the side the number landed on, nil for zero
      def side_of(number)
        @side_by_number[number]
      end

      NUMBERS = (1..36).to_a.freeze
      RED_NUMBERS = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36].freeze

      COLOR = new(:color, payout: 1, sides: {
                    Table::RED => RED_NUMBERS,
                    Table::BLACK => NUMBERS - RED_NUMBERS
                  })
      LOW_HIGH = new(:lowhigh, payout: 1, sides: {
                       Table::LOW => 1..18,
                       Table::HIGH => 19..36
                     })
      EVEN_ODD = new(:evenodd, payout: 1, sides: {
                       Table::EVEN => NUMBERS.select(&:even?),
                       Table::ODD => NUMBERS.select(&:odd?)
                     })
      DOZEN = new(:dozen, payout: 2, sides: {
                    Table::DOZEN_1 => 1..12,
                    Table::DOZEN_2 => 13..24,
                    Table::DOZEN_3 => 25..36
                  })
      COLUMN = new(:column, payout: 2, sides: {
                     Table::COLUMN_1 => NUMBERS.select { |number| number % 3 == 1 },
                     Table::COLUMN_2 => NUMBERS.select { |number| number % 3 == 2 },
                     Table::COLUMN_3 => NUMBERS.select { |number| (number % 3).zero? }
                   })
    end
  end
end
