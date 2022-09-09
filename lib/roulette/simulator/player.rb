module Roulette
  module Simulator
    class Player

        attr_reader :stats

      def initialize(table, account, draw_request_count = 10_000)
        @stats = {
          bet_count: 0,
          win: 0,
          lose: 0,
          draw_count: 0,
          max_bet: 0
        }

        @draw_request_count = draw_request_count
        @account = account
        @table = table
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

          Roulette::Simulator::SingletonLogger.instance.debug("bet_data: #{bet_data}")

          @stats[:bet_count] += 1
          @stats[:max_bet] = [@stats[:max_bet], bet_data.sum].max

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

      end

      def bet
        bet_data = Roulette::Simulator::BetData.new
        bet_data = Roulette::Simulator::Decisions::HistoryColorDecision.new(@table).calculate(bet_data)
        bet_data = Roulette::Simulator::Decisions::HistoryDozenDecision.new(@table).calculate(bet_data)
        bet_data = Roulette::Simulator::Decisions::HistoryColumnDecision.new(@table).calculate(bet_data)
        bet_data = Roulette::Simulator::Decisions::HistoryLowHighDecision.new(@table).calculate(bet_data)
        bet_data
      end

    end
  end
end
