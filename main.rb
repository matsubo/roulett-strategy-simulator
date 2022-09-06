require 'bundler'

Bundler.require(:default)

class Result
  attr_reader :number

  def initialize(number)
    raise 'invalid number' unless (0..36).include?(number)

    @number = number

    @color = if red?
               '🔴'
             elsif black?
               '⚫'
             else
               '🟢'
             end
  end

  def color
    return Roulette::RED if red?
    return Roulette::BLACK if black?

    nil
  end

  def red?
    return false if @number.zero?

    @number.odd?
  end

  def black?
    return false if @number.zero?

    @number.even?
  end

  def dozen
    return nil if @number.zero?
    return 1 if (1..12).include?(@number)
    return 2 if (13..24).include?(@number)
    return 3 if (25..36).include?(@number)

    raise
  end

  def column
    return nil if @number.zero?

    first_columns = [1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34]
    return 1 if first_columns.include?(@number)
    return 2 if first_columns.map { |n| n + 1 }.include?(@number)
    return 3 if first_columns.map { |n| n + 2 }.include?(@number)

    raise
  end
end

#
# Europian roulette
#
class Roulette
  RED = 1
  BLACK = 2

  attr_reader :histories

  def initialize
    @histories = []
  end

  def draw
    result = Result.new(rand(0..36))
    @histories << result
    result
  end

  def self.the_other_color(color)
    return RED if color == BLACK
    return BLACK if color == RED
  end
end

class Bet
  attr_reader :singles, :colors

  def initialize
    @singles = Hash.new(0)
    @colors = Hash.new(0)
  end

  def single(number, bet)
    @singles[number] += bet
  end

  def color(color, bet)
    @colors[color] += bet
  end

  def count
    @singles.values.sum + @colors.values.sum
  end
end

class Reward
  def self.calculate(bet, result)
    reward = 0

    # single
    reward += begin
      bet.singles[result.number] * 36
    rescue StandardError
      0
    end

    # colors
    reward += begin
      bet.colors[result.color] * 2
    rescue StandardError
      0
    end

    reward
  end
end

class RandomSinglleDecision
  def initialize(account, roulette = nil)
    @account = account
    @roulette = roulette
  end

  # @params Bet
  # @return Bet
  def calculate(bet)
    bet_price = 1
    bet_number = rand(0..36)
    bet.single(bet_number, bet_price)

    @account.minus(bet_price)

    bet
  end
end

class RandomColorDecision
  def initialize(account, roulette = nil)
    @account = account
    @roulette = roulette
  end

  # @params Bet
  # @return Bet
  def calculate(bet)
    bet_price = 1
    bet.color([Roulette::RED, Roulette::BLACK].sample, bet_price)

    @account.minus(bet_price)

    bet
  end
end

class HistoryColorDecision
  def initialize(account, roulette = nil)
    @account = account
    @roulette = roulette
  end

  # @params Bet
  # @return Bet
  def calculate(bet)
    # skip to collect data
    return bet if @roulette.histories.count < 20

    last_color = @roulette.histories[-1].color
    continuous = 0

    index = -1
    while index != @roulette.histories.count
      if @roulette.histories[index].color == last_color
        continuous += 1
        index -= 1
      else
        break
      end
    end

    return bet if continuous < 6

    bet_price = 2**(continuous - 6)

    bet.color(Roulette.the_other_color(last_color), bet_price)

    puts "credit: #{@account.credit}"
    puts "bet: #{bet_price}"

    @account.minus(bet_price)

    return bet
  end
end

class Account
  attr_reader :credit, :histories, :min, :max

  def initialize(credit = 500)
    @credit = @min = @max = credit
    @histories = []
  end

  def plus(number)
    @credit += number
    @histories << number

    calculate_statistics
  end

  def minus(number)
    raise 'credit will be negative value' if (@credit - number) < 0

    @credit -= number
    @histories << (-1 * number)

    calculate_statistics
  end

  # @see https://www.oanda.jp/lab-education/blog_30strategy/4345/
  def calculate_statistics
    @min = [@min, @credit].min
    @max = [@max, @credit].max
  end
end

class Player
  def initialize
    @bet_count = 0
    @win = @lose = 0
    @draw_count = 10_000
    @initial_credit = 500

    @account = Account.new(@initial_credit)
    @roulette = Roulette.new
    @decision = HistoryColorDecision.new(@account, @roulette)
  end

  def draw
    @draw_count.times do
      begin
        bet = @decision.calculate(Bet.new)
      rescue StandardError
        pp @roulette.histories
        raise
      end
      result = @roulette.draw

      # puts "result.number: #{result.number}"

      next unless bet.count.positive?

      @bet_count += 1
      reward = Reward.calculate(bet, result)
      # puts "reward: #{reward}"
      @account.plus(reward)

      if reward.positive?
        @win += 1
      else
        @lose += 1
      end
    end

    puts '----'
    puts "Draw: #{@draw_count}"
    puts "Bet count: #{@bet_count}"
    puts "Bet ratio: #{(@bet_count.quo(@draw_count).to_f * 100).round(3)}%"
    puts "Credit: #{@account.credit}"
    puts "Absolute Drawdown: #{(@account.min.quo(@account.credit).to_f * 100).round(3)}%"
    puts "PL(%): #{((@account.credit.quo(@initial_credit).to_f - 1) * 100).round(3)}%"
    puts "Win: #{@win}"
    puts "Lose: #{@lose}"
    puts "Won(%): #{(@win.quo(@win + @lose).to_f * 100).round(3)} %"

    # puts '----'
    # puts 'result debug'
    # pp Hash[@roulette.histories.map(&:number).group_by(&:itself).map {|k, v| [k, v.size] }].sort
    #
  end
end

Player.new.draw
