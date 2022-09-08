module Roulette
  module Simulator
    module Decisions
      class RandomSinglleDecision
        def initialize(table = nil)
          @table = table
        end

        # @params Bet
        # @return Bet
        def calculate(bet)
          bet_price = 1
          bet_number = rand(0..36)
          bet.single(bet_number, bet_price)
          bet
        end
      end

      class RandomColorDecision
        def initialize(table = nil)
          @table = table
        end

        # @params Bet
        # @return Bet
        def calculate(bet)
          bet_price = 1
          bet.color([Roulette::Simulator::Table::RED, Roulette::Simulator::Table::BLACK].sample, bet_price)
          bet
        end
      end

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

          last_color = @table.histories[-1].color

          continuous = 0

          index = 0
          while index != @table.histories.count
            index -= 1
            next if @table.histories[index].color.nil? # 0を無視しないとbetが途中で止まってしまう

            if @table.histories[index].color == last_color
              continuous += 1
            else
              break
            end
          end

          return bet if continuous < CONTINUOUS_COUNT

          # マーチンゲール法
          bet_price = 2**(continuous - CONTINUOUS_COUNT)

          bet.color(Roulette::Simulator::Table.the_other_color(last_color), bet_price)

          bet
        end
      end

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

          last_lowhigh = @table.histories[-1].lowhigh

          continuous = 0

          index = 0
          while index != @table.histories.count
            index -= 1
            next if @table.histories[index].lowhigh.nil? # 0を無視しないとbetが途中で止まってしまう

            if @table.histories[index].lowhigh == last_lowhigh
              continuous += 1
            else
              break
            end
          end

          return bet if continuous < CONTINUOUS_COUNT

          # マーチンゲール法
          bet_price = 2**(continuous - CONTINUOUS_COUNT)

          if last_lowhigh == Roulette::Simulator::Table::LOW
            bet.lowhigh(Roulette::Simulator::Table::HIGH, bet_price)
          elsif last_lowhigh == Roulette::Simulator::Table::LOW
            bet.lowhigh(Roulette::Simulator::Table::LOW, bet_price)
          end

          bet
        end
      end

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

          last_dozen = @table.histories[-1].dozen

          continuous = 0

          index = 0
          while index != @table.histories.count
            index -= 1
            next if @table.histories[index].dozen.nil? # 0を無視しないとbetが途中で止まってしまう

            if @table.histories[index].dozen == last_dozen
              continuous += 1
            else
              break
            end
          end

          return bet if continuous < CONTINUOUS_COUNT

          # マーチンゲール法
          bet_price = 3**(continuous - CONTINUOUS_COUNT)

          if last_dozen != Roulette::Simulator::Table::DOZEN_1
            bet.dozen(Roulette::Simulator::Table::DOZEN_1,
                      bet_price)
          end
          if last_dozen != Roulette::Simulator::Table::DOZEN_2
            bet.dozen(Roulette::Simulator::Table::DOZEN_2,
                      bet_price)
          end
          if last_dozen != Roulette::Simulator::Table::DOZEN_3
            bet.dozen(Roulette::Simulator::Table::DOZEN_3,
                      bet_price)
          end

          bet
        end
      end
    end
  end
end
