#
# Europian roulette
#
module Roulette
  module Simulator
    class Table
      RED = 1
      BLACK = 2

      DOZEN_1 = 11
      DOZEN_2 = 12
      DOZEN_3 = 13

      COLUMN_1 = 21
      COLUMN_2 = 22
      COLUMN_3 = 23

      LOW = 31
      HIGH = 32

      attr_reader :histories

      def initialize(random)
        @histories = []
        @draw_count = 0
        @random = random
      end

      def draw
        @draw_count += 1
        result = Result.new(@draw_count, @random.rand(0..36))
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
