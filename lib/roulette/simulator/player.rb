
require 'debug' # for .pretty_inspect
module Roulette
  module Simulator
    class Player
      def initialize
        @bet_count = 0
        @win = @lose = 0
        @draw_count = 0
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

          @draw_count += 1

          Roulette::Simulator::SingletonLogger.instance.info(result)

          # skip reward calculation if no bet
          next unless bet_data.sum.positive?

          Roulette::Simulator::SingletonLogger.instance.debug("bet_data: #{bet_data.pretty_inspect}")

          @bet_count += 1

          reward = Roulette::Simulator::Reward.calculate(bet_data, result)

          unless reward.positive?
            @lose += 1
            next
          end

          Roulette::Simulator::SingletonLogger.instance.debug("reward: #{reward}")

          @account.plus(reward, draw_count)
          @win += 1

          Roulette::Simulator::SingletonLogger.instance.debug("account balance: #{@account.credit}")
        end

        stats
      end

      def bet
        bet_data = Roulette::Simulator::BetData.new
        bet_data = Roulette::Simulator::Decisions::HistoryColorDecision.new(@table).calculate(bet_data)
        bet_data = Roulette::Simulator::Decisions::HistoryDozenDecision.new(@table).calculate(bet_data)
        Roulette::Simulator::Decisions::HistoryLowHighDecision.new(@table).calculate(bet_data)
      end

      def stats
        puts 'Result distribution:'
        @table.histories.map(&:number).group_by(&:itself).map { |k, v| [k, v.size] }.to_h.sort.each do |k, v|
          puts format('%2d', k) + ': ' + ('*' * (v / 10)) + " #{v}"
        end
        puts 'Credit history'
        @account.records.each_with_index do |record, index|

          # header
          print format('%4d', record.draw_count) + ': '

          # negative
          stars = record.current_credit.negative? ? record.current_credit.abs : 0
          print sprintf('%100s', '*' * [(stars / 10), 100].min)
          print "|"

          # positive
          if record.current_credit.positive?
            print ('*' * (record.current_credit / 10))
          end
          puts " #{record.current_credit}"
        end
        puts "Draw request: #{@draw_request_count}"
        puts "Draw executed: #{@draw_count}"
        puts "Bet count: #{@bet_count}"
        puts "Bet ratio: #{(@bet_count.quo(@draw_count).to_f * 100).round(3)}%"
        puts "Credit: #{@account.credit}"
        puts "Absolute Drawdown: #{(@account.min.quo(@account.credit).to_f * 100).round(3)}%"
        puts "PL(%): #{((@account.credit.quo(@initial_credit).to_f - 1) * 100).round(3)}%"
        puts "Win: #{@win}"
        puts "Lose: #{@lose}"
        puts "Won(%): #{(@win.quo(@win + @lose).to_f * 100).round(3)} %"
      end
    end
  end
end
