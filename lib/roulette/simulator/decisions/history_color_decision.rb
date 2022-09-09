module Roulette
  module Simulator
    module Decisions
      class HistoryColorDecision
        # 何回連続で出たらbetし始めるか
        CONTINUOUS_COUNT = 6

        def initialize(table = nil)
          @table = table
        end

        # @params Bet
        # @return Bet
        def calculate(bet)
          # skip to collect data
          return bet if @table.histories.count < 10

          last_color = nil

          continuous = 0

          zero_count = 0

          index = -1

          while @table.histories[index]
            
            if @table.histories[index].color.nil? # 0を無視しないとbetが途中で止まってしまう
              index -= 1
              zero_count += 1
              next
            end

            last_color = last_color || @table.histories[index].color

            if @table.histories[index].color == last_color
              continuous += 1
              index -= 1
            else
              break
            end
          end

          return bet if continuous < CONTINUOUS_COUNT

          # マーチンゲール法
          bet_price = 2**(continuous - CONTINUOUS_COUNT + zero_count)

          bet.color(Roulette::Simulator::Table.the_other_color(last_color), bet_price)

          bet
        end
      end
    end
  end
end
