module Roulette
  module Simulator
    # What one bet type did over a day: stakes placed and amounts returned (stake included).
    BetTally = Struct.new(:bets, :wins, :staked, :returned, :max_stake) do
      def self.empty
        new(0, 0, 0, 0, 0)
      end

      def add(staked, returned)
        self.bets += 1
        self.wins += 1 if returned > staked
        self.staked += staked
        self.returned += returned
        self.max_stake = [max_stake, staked].max
      end

      def net
        returned - staked
      end

      def +(other)
        BetTally.new(bets + other.bets, wins + other.wins, staked + other.staked, returned + other.returned,
                     [max_stake, other.max_stake].max)
      end
    end

    # The result of one day of play.
    #
    # bankroll    - bankroll after each spin; index 0 is the starting bankroll
    # bankrupt_at - the spin (1-based) whose wager the bankroll could not cover, or nil
    # by_bet      - BetTally per bet (:single, :color, :lowhigh, :evenodd, :dozen, :column) that was played
    # total       - BetTally over whole wagers: one entry per spin with a stake
    DayOutcome = Data.define(:bankroll, :bankrupt_at, :by_bet, :total) do
      def bankrupt?
        !bankrupt_at.nil?
      end

      def spins_played
        bankroll.size - 1
      end

      def final_bankroll
        bankroll.last
      end

      # Largest fall from a running peak, as a fraction of that peak.
      def max_drawdown
        peak = bankroll.first
        bankroll.map do |value|
          peak = [peak, value].max
          peak.zero? ? 0.0 : (peak - value).fdiv(peak)
        end.max
      end
    end
  end
end
