module Roulette
  module Simulator
    module Decisions
      class HistoryColumnDecision

        # 何回連続で出たらbetし始めるか
        CONTINUOUS_COUNT = 4 # 0.99588477

        def initialize(table)
          @table = table
        end

        # @params Bet
        # @return Bet
        def calculate(bet)
          # skip to collect data
          return bet if @table.histories.count < 10

          last_column = @table.histories[-1].column

          continuous = 0

          index = 0
          while index != @table.histories.count
            index -= 1
            next if @table.histories[index].column.nil? # 0を無視しないとbetが途中で止まってしまう

            if @table.histories[index].column == last_column
              continuous += 1
            else
              break
            end
          end

          return bet if continuous < CONTINUOUS_COUNT

          # マーチンゲール法
          bet_price = 3**(continuous - CONTINUOUS_COUNT)

          if last_column != Roulette::Simulator::Table::COLUMN_1
            bet.column(Roulette::Simulator::Table::COLUMN_1,
                      bet_price)
          end
          if last_column != Roulette::Simulator::Table::COLUMN_2
            bet.column(Roulette::Simulator::Table::COLUMN_2,
                      bet_price)
          end
          if last_column != Roulette::Simulator::Table::COLUMN_3
            bet.column(Roulette::Simulator::Table::COLUMN_3,
                      bet_price)
          end

          bet
        end
      end
    end
  end
end
