module Roulette
  module Simulator
    class Account
      attr_reader :credit

      def initialize(credit)
        @credit = credit
      end

      def plus(number)
        @credit += number.abs
      end

      def minus(number)
        if (@credit - number).negative?
          raise Roulette::Simulator::Exception::BalanceIsNotEnough,
                "credit will be negative value. credit: #{@credit}, withdraw request: #{number}"
        end

        @credit -= number.abs
      end
    end
  end
end
