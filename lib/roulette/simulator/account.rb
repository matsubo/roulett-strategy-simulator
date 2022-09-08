module Roulette
  module Simulator
    class Account
      attr_reader :credit, :records, :min, :max

      def initialize(credit)
        @credit = @min = @max = credit
        @records = []
      end

      def plus(number, draw_count = nil)
        @records << Record.new(@credit, number, draw_count)

        @credit += number

        calculate_statistics
      end

      def minus(number, draw_count = nil)

        # raise "credit will be negative value. credit: #{@credit}, withdraw request: #{number}" if (@credit - number) < 0

        @records << Record.new(@credit, number, draw_count)

        @credit -= number

        calculate_statistics
      end

      # @see https://www.oanda.jp/lab-education/blog_30strategy/4345/
      def calculate_statistics
        @min = [@min, @credit].min
        @max = [@max, @credit].max
      end
    end
  end
end
