require 'debug' # for .pretty_inspect
module Roulette
  module Simulator
    class Player
      def initialize
        @stats = {
          bet_count: 0,
          win: 0,
          lose: 0,
          draw_count: 0
        }

        @draw_request_count = 10_000 # (12 hours * 60 minutes) / 2 minutes each = 360
        @initial_credit = 500

        @account = Roulette::Simulator::Account.new(@initial_credit)
        @table = Roulette::Simulator::Table.new
      end

      def draw
        @draw_request_count.times do |draw_count|
          Roulette::Simulator::SingletonLogger.instance.debug("draw count: #{draw_count}")
          Roulette::Simulator::SingletonLogger.instance.debug("credit: #{@account.credit}")

          # bet
          bet_data = bet

          begin
            @account.minus(bet_data.sum, draw_count) if bet_data.sum.positive?
          rescue StandardError
            stats
            raise
          end

          Roulette::Simulator::SingletonLogger.instance.debug(bet) if bet.sum.positive?

          # draw
          result = @table.draw

          @stats[:draw_count] += 1

          Roulette::Simulator::SingletonLogger.instance.info(result)

          # skip reward calculation if no bet
          next unless bet_data.sum.positive?

          Roulette::Simulator::SingletonLogger.instance.debug("bet_data: #{bet_data.pretty_inspect}")

          @stats[:bet_count] += 1

          reward = Roulette::Simulator::Reward.calculate(bet_data, result)

          unless reward.positive?
            @stats[:lose] += 1
            next
          end

          # return reward to the player
          Roulette::Simulator::SingletonLogger.instance.debug("reward: #{reward}")

          @account.plus(reward, draw_count)
          @stats[:win] += 1

          Roulette::Simulator::SingletonLogger.instance.debug("account balance: #{@account.credit}")
        end

        stats
      end

      def bet
        bet_data = Roulette::Simulator::BetData.new
        bet_data = Roulette::Simulator::Decisions::HistoryColorDecision.new(@table).calculate(bet_data)
        bet_data = Roulette::Simulator::Decisions::HistoryDozenDecision.new(@table).calculate(bet_data)
        bet_data = Roulette::Simulator::Decisions::HistoryLowHighDecision.new(@table).calculate(bet_data)
        bet_data
      end

      def stats

        puts "Draw request: #{@draw_request_count}"
        puts "Draw executed: #{@stats[:draw_count]}"
        puts "Bet count: #{@stats[:bet_count]}"
        puts "Bet ratio: #{(@stats[:bet_count].quo(@stats[:draw_count]).to_f * 100).round(3)}%"
        puts "Credit: #{@account.credit}"
        puts "Absolute Drawdown: #{(@account.min.quo(@account.credit).to_f * 100).round(3)}%"
        puts "PL(%): #{((@account.credit.quo(@initial_credit).to_f - 1) * 100).round(3)}%"
        puts "Win: #{@stats[:win]}"
        puts "Lose: #{@stats[:lose]}"
        puts "Won(%): #{(@stats[:win].quo(@stats[:win] + @stats[:lose]).to_f * 100).round(3)} %"


        # for gnuplot data
        require 'gr/plot'

        x = []
        y = []
        @account.records.each do |record|
          x << record.draw_count
          y << record.current_credit
        end

        GR.plot(x, y, GR.subplot(2, 1, 1))

        # histogram
        x = []
        y = []
        @table.histories.map(&:number).group_by(&:itself).map { |k, v| [k, v.size] }.to_h.sort.each do |k, v|
            x << k
            y << v
        end

        GR.barplot(x, y, GR.subplot(2, 1, 2))

        debugger

        GR.savefig('image.png')

      end
    end
  end
end



# require 'gr/plot'
# 
# x = [1,2,3,4,5,6,7,8,9,10]
# y = x.shuffle

# GR.barplot x, y, GR.subplot(2, 2, 1)
# GR.stem    x, y, GR.subplot(2, 2, 2)
# GR.step    x, y, GR.subplot(2, 2, 3)
# GR.plot    x, y, GR.subplot(2, 2, 4)
