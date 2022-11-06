module Roulette
  module Simulator
    module Decisions
      class HistoryEvenOddDecision
        # 何回連続で出たらbetし始めるか
        CONTINUOUS_COUNT = 6 # 0.9921875

        def initialize(table = nil)
          @table = table
        end

        # @params Bet
        # @return Bet
        def calculate(bet)
          # skip to collect data
          return bet if @table.histories.count < 10

          last_evenodd = nil

          continuous = 0

          zero_count = 0

          index = 0
          while @table.histories[index]

            if @table.histories[index].evenodd.nil? # 0を無視しないとbetが途中で止まってしまう
              index -= 1
              zero_count += 1
              next
            end

            last_evenodd ||= @table.histories[index].evenodd

            break unless @table.histories[index].evenodd == last_evenodd

            continuous += 1
            index -= 1

          end

          return bet if continuous < CONTINUOUS_COUNT

          # マーチンゲール法
          bet_price = 2**(continuous - CONTINUOUS_COUNT + zero_count)

          if last_evenodd == Roulette::Simulator::Table::EVEN
            bet.evenodd(Roulette::Simulator::Table::ODD, bet_price)
          elsif last_evenodd == Roulette::Simulator::Table::ODD
            bet.evenodd(Roulette::Simulator::Table::EVEN, bet_price)
          end

          bet
        end
      end
    end
  end
end
