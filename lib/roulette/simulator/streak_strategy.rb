require_relative 'outside_bet'

module Roulette
  module Simulator
    # Bets against a streak on one outside bet once the streak reaches the trigger.
    # The stake is multiplied by (payout + 1) for every lost bet in the current streak.
    class StreakStrategy
      WARM_UP_SPINS = 10

      attr_reader :outside_bet

      def initialize(outside_bet, trigger:)
        @outside_bet = outside_bet
        @trigger = trigger
      end

      # @param spins [Array<Integer>] numbers spun so far, oldest first
      # @return [Hash{Integer => Integer}] side => stake for the next spin; empty when not betting
      def wager(spins)
        return {} if spins.size < WARM_UP_SPINS

        streak_side, run = streak(spins)
        lost_bets = lost_bets(run)
        return {} unless lost_bets

        stake = (@outside_bet.payout + 1)**lost_bets
        (@outside_bet.sides - [streak_side]).to_h { |side| [side, stake] }
      end

      private

      # @return [Integer, nil] spins in the run after the trigger was reached; nil when it never was
      def lost_bets(run)
        on_streak = 0
        run.each_with_index do |side, index|
          on_streak += 1 if side
          return run.size - index - 1 if on_streak == @trigger
        end
        nil
      end

      # @return [Array(Integer, Array<Integer, nil>)] the streak's side and its spins' sides, oldest first,
      #   with zeros kept as nil
      def streak(spins)
        streak_side = nil
        run = []
        spins.reverse_each do |number|
          side = @outside_bet.side_of(number)
          streak_side ||= side
          break if side && side != streak_side

          run << side
        end
        [streak_side, run.reverse]
      end
    end
  end
end
