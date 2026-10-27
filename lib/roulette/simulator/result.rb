require_relative 'outside_bet'

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

        @column = column

        @evenodd = evenodd
      end

      def color
        OutsideBet::COLOR.side_of(@number)
      end

      def lowhigh
        OutsideBet::LOW_HIGH.side_of(@number)
      end

      def evenodd
        OutsideBet::EVEN_ODD.side_of(@number)
      end

      def red?
        color == Table::RED
      end

      def black?
        color == Table::BLACK
      end

      def dozen
        OutsideBet::DOZEN.side_of(@number)
      end

      def column
        OutsideBet::COLUMN.side_of(@number)
      end
    end
  end
end
