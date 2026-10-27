require 'minitest/autorun'
require_relative '../lib/roulette/simulator/statistics'

class StatisticsTest < Minitest::Test
  BetTally = Roulette::Simulator::BetTally
  DayOutcome = Roulette::Simulator::DayOutcome

  def day(bankroll, bankrupt_at: nil, by_bet: {}, total: BetTally.empty)
    DayOutcome.new(bankroll: bankroll, bankrupt_at: bankrupt_at, by_bet: by_bet, total: total)
  end

  def stats(outcomes, spins: 4)
    Roulette::Simulator::Statistics.new(outcomes, spins: spins, initial_bankroll: 100)
  end

  def test_max_drawdown_is_measured_from_the_running_peak
    assert_in_delta 0.5, day([100, 120, 60, 110, 200]).max_drawdown
    assert_in_delta 0.0, day([100, 110, 120]).max_drawdown
  end

  def test_percentile_interpolates_between_ranks
    assert_in_delta 2.5, Roulette::Simulator::Statistics.percentile([4, 1, 3, 2], 50)
    assert_equal 4, Roulette::Simulator::Statistics.percentile([4, 1, 3, 2], 100)
  end

  def test_bankrupt_day_holds_its_last_bankroll_in_bands_and_leaves_survival
    run = stats([day([100, 90, 40], bankrupt_at: 3), day([100, 110, 120, 130, 140])])

    assert_equal [100, 90, 40, 40, 40], run.bankroll_path(run.outcomes.first)
    assert_equal [100.0, 100.0, 80.0, 85.0, 90.0], run.bankroll_bands.fetch(50)
    assert_equal [1.0, 1.0, 1.0, 0.5, 0.5], run.survival
    assert_equal 1, run.bankrupt_days
    assert_equal 1, run.profitable_days
  end

  def test_histogram_bins_cover_every_final_bankroll_once
    run = stats([day([100, 3]), day([100, 50]), day([100, 50]), day([100, 241])], spins: 1)
    bins = run.final_bankroll_histogram(bins: 5)

    assert_equal(4, bins.sum { |bin| bin[:count] })
    assert_equal 3, bins.first[:from]
    assert_operator bins.last[:to], :>, 241
    bins.each_cons(2) { |left, right| assert_equal left[:to], right[:from] }
  end

  def test_tallies_sum_across_days_and_skip_unplayed_bets
    first = day([100, 102], by_bet: { color: BetTally.new(2, 1, 3, 2, 2) }, total: BetTally.new(2, 1, 3, 2, 2))
    second = day([100, 101], by_bet: { color: BetTally.new(1, 1, 4, 8, 4), dozen: BetTally.new(1, 0, 2, 0, 2) },
                             total: BetTally.new(1, 1, 6, 8, 6))
    run = stats([first, second], spins: 1)

    assert_equal %i[color dozen], run.by_bet.keys
    assert_equal BetTally.new(3, 2, 7, 10, 4), run.by_bet[:color]
    assert_in_delta 10.0 / 9, run.return_to_player
  end
end
