module Roulette
  module Simulator
    module Decisions
      class HistoryLowHighDecision
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

          last_lowhigh = nil

          continuous = 0

          zero_count = 0

          index = 0
          while @table.histories[index]

            if @table.histories[index].lowhigh.nil? # 0を無視しないとbetが途中で止まってしまう
              index -= 1
              zero_count += 1
              next
            end

            last_lowhigh ||= @table.histories[index].lowhigh

            break unless @table.histories[index].lowhigh == last_lowhigh

            continuous += 1
            index -= 1

          end

          return bet if continuous < CONTINUOUS_COUNT

          # マーチンゲール法
          bet_price = 2**(continuous - CONTINUOUS_COUNT + zero_count)

          if last_lowhigh == Roulette::Simulator::Table::LOW
            bet.lowhigh(Roulette::Simulator::Table::HIGH, bet_price)
          elsif last_lowhigh == Roulette::Simulator::Table::HIGH
            bet.lowhigh(Roulette::Simulator::Table::LOW, bet_price)
          end

          bet
        end
      end
    end
  end
end
