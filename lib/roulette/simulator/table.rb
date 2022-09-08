#
# Europian roulette
#
module Roulette
  module Simulator
    class Table
      RED = 1
      BLACK = 2

      DOZEN_1 = 1
      DOZEN_2 = 2
      DOZEN_3 = 3

      LOW = 1
      HIGH = 2

      attr_reader :histories

      def initialize
        @histories = []
        @draw_count = 0
      end

      def draw
        @draw_count += 1
        result = Result.new(@draw_count, rand(0..36))
        @histories << result
        result
      end

      def self.the_other_color(color)
        return RED if color == BLACK
        return BLACK if color == RED
      end
    end
  end
end
