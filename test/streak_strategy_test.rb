require 'minitest/autorun'
require_relative '../lib/roulette/simulator/streak_strategy'

class StreakStrategyTest < Minitest::Test
  OutsideBet = Roulette::Simulator::OutsideBet
  Table = Roulette::Simulator::Table

  R = 1  # red
  B = 2  # black
  Z = 0  # zero
  PREFIX = [B] * 4 # gets past the warm-up and bounds the red streak

  def color(trigger: 6)
    Roulette::Simulator::StreakStrategy.new(OutsideBet::COLOR, trigger: trigger)
  end

  def test_never_bets_during_warm_up
    assert_empty color.wager([R] * 9)
  end

  def test_no_bet_below_trigger
    assert_empty color.wager(([B] * 5) + ([R] * 5))
  end

  def test_no_bet_when_newest_spin_breaks_the_streak
    assert_empty color.wager(PREFIX + ([R] * 6) + [B])
  end

  def test_bets_one_unit_against_streak_at_trigger
    assert_equal({ Table::BLACK => 1 }, color.wager(PREFIX + ([R] * 6)))
  end

  def test_stake_doubles_per_lost_bet
    assert_equal({ Table::BLACK => 2 }, color.wager(PREFIX + ([R] * 7)))
  end

  def test_zero_before_trigger_is_not_a_lost_bet
    assert_equal({ Table::BLACK => 1 }, color.wager(PREFIX + [R, R, Z, R, R, R, R]))
  end

  def test_zero_after_trigger_is_a_lost_bet
    assert_equal({ Table::BLACK => 2 }, color.wager(PREFIX + ([R] * 6) + [Z]))
    assert_equal({ Table::BLACK => 8 }, color.wager(PREFIX + ([R] * 6) + [Z, Z, R]))
  end

  def test_streak_is_read_from_the_newest_spin
    low = 1
    high = 19
    strategy = Roulette::Simulator::StreakStrategy.new(OutsideBet::LOW_HIGH, trigger: 6)

    assert_equal({ Table::LOW => 1 }, strategy.wager(([low] * 4) + ([high] * 6)))
  end

  def test_two_to_one_bet_covers_both_other_sides_and_triples
    first_dozen = [1, 2, 3, 4, 5, 6]
    strategy = Roulette::Simulator::StreakStrategy.new(OutsideBet::DOZEN, trigger: 5)
    history = ([13] * 4) + first_dozen

    assert_equal({ Table::DOZEN_2 => 3, Table::DOZEN_3 => 3 }, strategy.wager(history))
  end
end
