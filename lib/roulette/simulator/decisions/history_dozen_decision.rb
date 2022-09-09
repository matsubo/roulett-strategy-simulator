module Roulette
  module Simulator
    module Decisions
      class HistoryDozenDecision
        # 何回連続で出たらbetし始めるか
        CONTINUOUS_COUNT = 4 # 0.99588477

        def initialize(table = nil)
          @table = table
        end

        # @params Bet
        # @return Bet
        def calculate(bet)
          # skip to collect data
          return bet if @table.histories.count < 10

          last_dozen = nil

          continuous = 0

          zero_count = 0

          index = -1
          while @table.histories[index]

             # 0を無視しないとbetが途中で止まってしまう
            if @table.histories[index].dozen.nil?
                index -= 1
                zero_count += 1
                next
            end

            last_dozen = last_dozen || @table.histories[index].dozen

            if @table.histories[index].dozen == last_dozen
              continuous += 1
              index -= 1
            else
              break
            end
          end

          return bet if continuous < CONTINUOUS_COUNT

          # マーチンゲール法
          bet_price = 3**(continuous - CONTINUOUS_COUNT + zero_count)

          if last_dozen != Roulette::Simulator::Table::DOZEN_1
            bet.dozen(Roulette::Simulator::Table::DOZEN_1, bet_price)
          end
          if last_dozen != Roulette::Simulator::Table::DOZEN_2
            bet.dozen(Roulette::Simulator::Table::DOZEN_2, bet_price)
          end
          if last_dozen != Roulette::Simulator::Table::DOZEN_3
            bet.dozen(Roulette::Simulator::Table::DOZEN_3, bet_price)
          end

          bet
        end
      end
    end
  end
end
