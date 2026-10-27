require_relative 'day_outcome'

module Roulette
  module Simulator
    # Figures over a run of days; every report reads from here.
    class Statistics
      BET_ORDER = %i[color lowhigh evenodd dozen column single].freeze
      BAND_PERCENTILES = [5, 25, 50, 75, 95].freeze

      attr_reader :outcomes, :spins, :initial_bankroll

      # @param outcomes [Array<DayOutcome>]
      def initialize(outcomes, spins:, initial_bankroll:)
        @outcomes = outcomes
        @spins = spins
        @initial_bankroll = initial_bankroll
      end

      def self.percentile(values, pct)
        return nil if values.empty?

        sorted = values.sort
        rank = (sorted.size - 1) * pct / 100.0
        lower = sorted[rank.floor]
        upper = sorted[rank.ceil]
        lower + ((upper - lower) * (rank - rank.floor))
      end

      def self.mean(values)
        values.empty? ? nil : values.sum.fdiv(values.size)
      end

      def days
        outcomes.size
      end

      def bankrupt_days
        outcomes.count(&:bankrupt?)
      end

      def median_bankrupt_spin
        self.class.percentile(outcomes.select(&:bankrupt?).map(&:bankrupt_at), 50)
      end

      def profitable_days
        final_bankrolls.count { |final| final > initial_bankroll }
      end

      def final_bankrolls
        outcomes.map(&:final_bankroll)
      end

      def median_final_bankroll
        self.class.percentile(final_bankrolls, 50)
      end

      # Mean of each day's profit as a fraction of the starting bankroll.
      def mean_profit_rate
        self.class.mean(final_bankrolls.map { |final| (final - initial_bankroll).fdiv(initial_bankroll) })
      end

      def drawdowns
        outcomes.map(&:max_drawdown)
      end

      def total
        sum_tallies(outcomes.map(&:total))
      end

      # Amount returned per unit staked over the whole run.
      def return_to_player
        total.staked.zero? ? nil : total.returned.fdiv(total.staked)
      end

      # @return [Hash{Symbol => BetTally}] tallies summed over all days, for bets that were played
      def by_bet
        BET_ORDER.filter_map do |bet|
          tallies = outcomes.filter_map { |outcome| outcome.by_bet[bet] }
          [bet, sum_tallies(tallies)] unless tallies.empty?
        end.to_h
      end

      # Bankroll percentiles at every spin; a bankrupt day keeps its last bankroll.
      # @return [Hash{Integer => Array<Float>}] percentile => value per spin 0..spins
      def bankroll_bands
        paths = outcomes.map { |outcome| bankroll_path(outcome) }
        BAND_PERCENTILES.to_h do |pct|
          [pct, (0..spins).map { |spin| self.class.percentile(paths.map { |path| path[spin] }, pct) }]
        end
      end

      # Share of days still playing at each spin 0..spins.
      def survival
        (0..spins).map do |spin|
          outcomes.count { |outcome| !outcome.bankrupt? || outcome.bankrupt_at > spin }.fdiv(days)
        end
      end

      # @return [Array<Hash>] equal-width bins over the final bankrolls: from (inclusive), to (exclusive), count
      def final_bankroll_histogram(bins: 20)
        low, high = final_bankrolls.minmax
        width = [((high - low + 1) / bins.to_f).ceil, 1].max
        counts = final_bankrolls.map { |final| (final - low) / width }.tally
        (0..((high - low) / width)).map do |index|
          { from: low + (index * width), to: low + ((index + 1) * width), count: counts.fetch(index, 0) }
        end
      end

      def bankroll_path(outcome)
        outcome.bankroll + ([outcome.final_bankroll] * (spins + 1 - outcome.bankroll.size))
      end

      private

      def sum_tallies(tallies)
        tallies.reduce(BetTally.empty, :+)
      end
    end
  end
end
