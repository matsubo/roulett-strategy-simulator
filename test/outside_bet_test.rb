require 'minitest/autorun'
require_relative '../lib/roulette/simulator/result'

class OutsideBetTest < Minitest::Test
  OutsideBet = Roulette::Simulator::OutsideBet
  Table = Roulette::Simulator::Table
  ALL = [OutsideBet::COLOR, OutsideBet::LOW_HIGH, OutsideBet::EVEN_ODD, OutsideBet::DOZEN, OutsideBet::COLUMN].freeze

  def test_zero_lands_on_no_side
    ALL.each { |outside_bet| assert_nil outside_bet.side_of(0), outside_bet.name }
  end

  def test_every_number_lands_on_one_side_and_sides_are_equal_size
    ALL.each do |outside_bet|
      landed = (1..36).map { |number| outside_bet.side_of(number) }

      assert_equal outside_bet.sides.sort, landed.uniq.sort, outside_bet.name
      assert_equal [36 / outside_bet.sides.size], landed.tally.values.uniq, outside_bet.name
    end
  end

  def test_color_follows_the_european_wheel_not_parity
    { 1 => Table::RED, 2 => Table::BLACK, 10 => Table::BLACK, 11 => Table::BLACK, 12 => Table::RED,
      18 => Table::RED, 19 => Table::RED, 28 => Table::BLACK, 29 => Table::BLACK, 36 => Table::RED }
      .each { |number, color| assert_equal color, OutsideBet::COLOR.side_of(number), number }
  end

  def test_group_edges
    assert_equal Table::LOW, OutsideBet::LOW_HIGH.side_of(18)
    assert_equal Table::HIGH, OutsideBet::LOW_HIGH.side_of(19)
    assert_equal Table::DOZEN_1, OutsideBet::DOZEN.side_of(12)
    assert_equal Table::DOZEN_2, OutsideBet::DOZEN.side_of(13)
    assert_equal Table::DOZEN_3, OutsideBet::DOZEN.side_of(25)
    assert_equal Table::COLUMN_1, OutsideBet::COLUMN.side_of(34)
    assert_equal Table::COLUMN_2, OutsideBet::COLUMN.side_of(35)
    assert_equal Table::COLUMN_3, OutsideBet::COLUMN.side_of(36)
  end

  def test_result_settles_on_the_same_color_as_the_outside_bet
    assert_equal Table::RED, Roulette::Simulator::Result.new(1, 12).color
    assert_equal Table::BLACK, Roulette::Simulator::Result.new(1, 11).color
  end
end
