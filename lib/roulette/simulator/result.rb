module Roulette
  module Simulator
    class Result
      attr_reader :number

      def initialize(draw_count, number)
        raise 'invalid number' unless (0..36).include?(number)

        @draw_count = draw_count

        @number = number

        @color = if red?
                   '🔴'
                 elsif black?
                   '⚫'
                 else
                   '🟢'
                 end

        @dozen = dozen

        @lowhigh = lowhigh
      end

      def color
        return Roulette::Simulator::Table::RED if red?
        return Roulette::Simulator::Table::BLACK if black?

        nil
      end

      def lowhigh
        return nil if @number.zero?

        if @number <= 18
          Roulette::Simulator::Table::LOW
        elsif 18 < @number
          Roulette::Simulator::Table::HIGH
        end
      end

      def red?
        return false if @number.zero?

        @number.odd?
      end

      def black?
        return false if @number.zero?

        @number.even?
      end

      def dozen
        return nil if @number.zero?
        return Roulette::Simulator::Table::DOZEN_1 if (1..12).include?(@number)
        return Roulette::Simulator::Table::DOZEN_2 if (13..24).include?(@number)
        return Roulette::Simulator::Table::DOZEN_3 if (25..36).include?(@number)

        raise
      end

      def column
        return nil if @number.zero?

        first_columns = [1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34]
        return Roulette::Simulator::Table::DOZEN_1 if first_columns.include?(@number)
        return Roulette::Simulator::Table::DOZEN_2 if first_columns.map { |n| n + 1 }.include?(@number)
        return Roulette::Simulator::Table::DOZEN_3 if first_columns.map { |n| n + 2 }.include?(@number)

        raise
      end
    end
  end
end
