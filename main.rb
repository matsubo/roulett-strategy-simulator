require 'bundler'

Bundler.require(:default)




class Result

  attr_reader :number

  def initialize(number)

    raise 'invalid number' unless (0..36).include?(number)

    @number = number
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

  attr_reader :histories
  def initialize
    @histories = []
  end

  def draw
    result = Result.new(rand(0..36))
    @histories << result
    result
  end

end


class Bet

  attr_reader :singles

  def initialize
    @singles = Hash.new(0)
  end

  def single(number, bet)
    @singles[number] += bet
  end

end


class Reward
  def self.calculate(bet, result)
    reward = 0

    # single
    reward += (bet.singles[result.number] * 36 rescue 0)

    return reward
  end
end


class RandomDecision

  def initialize(account, roulette = nil)
    @account = account
    @roulette = roulette
  end

  # @return Bet 
  def calculate
    bet = Bet.new

    bet_price = 1
    bet_number = rand(0..36)
    bet.single(bet_number, bet_price)

    @account.minus(bet_price)

    return bet
  end
end

class Account

  attr_reader :credit, :histories

  def initialize(credit = 10_000)
    @credit = credit
    @histories = []
  end

  def plus(number)
    @credit += number
    @histories << number
  end

  def minus(number)
    raise 'credit will be negative value' if (@credit - number) < 0
    @credit -= number
    @histories << -1 * number
  end
end


class Player

  def initialize
    @account = Account.new
    @roulette = Roulette.new
    @decision = RandomDecision.new(@account, @roulette)
  end


  def draw

    100000.times do
      bet = @decision.calculate
      result = @roulette.draw

      # puts "result.number: #{result.number}"

      reward = Reward.calculate(bet, result)

      # puts "reward: #{reward}"

      @account.plus(reward)
    end

    puts '----'
    puts @account.credit

    # puts '----'
    # puts 'result debug'
    # pp Hash[@roulette.histories.map(&:number).group_by(&:itself).map {|k, v| [k, v.size] }].sort
    #
  end

end


Player.new.draw


