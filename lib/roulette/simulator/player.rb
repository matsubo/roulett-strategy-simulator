module Roulette
  module Simulator
    # Plays one day at a table: places the strategies' wagers each spin and settles them.
    class Player
      STRATEGIES = [
        StreakStrategy.new(OutsideBet::COLOR, trigger: 6),
        StreakStrategy.new(OutsideBet::LOW_HIGH, trigger: 6),
        StreakStrategy.new(OutsideBet::EVEN_ODD, trigger: 6),
        StreakStrategy.new(OutsideBet::DOZEN, trigger: 5),
        StreakStrategy.new(OutsideBet::COLUMN, trigger: 5)
      ].freeze

      def initialize(table, account, spins)
        @table = table
        @account = account
        @spins = spins
      end

      # Plays up to the requested spins; the day ends early when the bankroll cannot cover a wager.
      # @return [DayOutcome]
      def play
        @bankroll = [@account.credit]
        @by_bet = {}
        @total = BetTally.empty

        bankrupt_at = nil
        begin
          @spins.times { play_spin }
        rescue Exception::BalanceIsNotEnough => e
          bankrupt_at = @bankroll.size
          logger.debug("spin #{bankrupt_at}: bankrupt (#{e.message})")
        end

        DayOutcome.new(bankroll: @bankroll, bankrupt_at: bankrupt_at, by_bet: @by_bet, total: @total)
      end

      def bet
        bet_data = Roulette::Simulator::BetData.new
        spins = @table.histories.map(&:number)

        STRATEGIES.each do |strategy|
          strategy.wager(spins).each { |side, stake| bet_data.place(strategy.outside_bet, side, stake) }
        end

        bet_data
      end

      private

      def play_spin
        bet_data = bet
        stake = bet_data.sum
        @account.minus(stake)

        result = @table.draw
        settle(bet_data, result) if stake.positive?
        @bankroll << @account.credit
        logger.debug("spin #{@bankroll.size - 1}: #{result.number}, stake #{stake}, bankroll #{@account.credit}")
      end

      def settle(bet_data, result)
        returned = Roulette::Simulator::Reward.by_bet(bet_data, result)
        bet_data.stakes_by_bet.each do |bet, staked|
          (@by_bet[bet] ||= BetTally.empty).add(staked, returned[bet]) if staked.positive?
        end
        @total.add(bet_data.sum, returned.values.sum)
        @account.plus(returned.values.sum)
      end

      def logger
        Roulette::Simulator::SingletonLogger.instance
      end
    end
  end
end
