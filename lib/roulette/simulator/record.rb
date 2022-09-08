module Roulette
  module Simulator
    class Record
      attr_reader :current_credit, :diff, :draw_count

      def initialize(current_credit, diff, draw_count)
        @current_credit = current_credit
        @diff = diff
        @draw_count = draw_count
      end
    end
  end
end
