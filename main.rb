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

    @dozen = dozen
  end

  def color
    return Roulette::RED if red?
    return Roulette::BLACK if black?

    nil
  end

  def lowhigh
    return nil if @number.zero?

    if @number <= 18
      Roulette::LOW
    elsif 18 < @number
      Roulette::HIGH
    end
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
    return Roulette::DOZEN_1 if (1..12).include?(@number)
    return Roulette::DOZEN_2 if (13..24).include?(@number)
    return Roulette::DOZEN_3 if (25..36).include?(@number)

    raise
  end

  def column
    return nil if @number.zero?

    first_columns = [1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34]
    return Roulette::DOZEN_1 if first_columns.include?(@number)
    return Roulette::DOZEN_2 if first_columns.map { |n| n + 1 }.include?(@number)
    return Roulette::DOZEN_3 if first_columns.map { |n| n + 2 }.include?(@number)

    raise
  end
end

#
# Europian roulette
#
class Roulette
  RED = 1
  BLACK = 2

  DOZEN_1 = 1
  DOZEN_2 = 2
  DOZEN_3 = 3

  LOW = 1
  HIGH = 2

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
  attr_reader :singles, :colors, :dozens, :lowhighs

  def initialize
    @singles = Hash.new(0)
    @colors = Hash.new(0)
    @dozens = Hash.new(0)
    @lowhighs = Hash.new(0)
  end

  def single(number, bet)
    @singles[number] += bet
  end

  def color(color, bet)
    @colors[color] += bet
  end

  def dozen(dozen, bet)
    @dozens[dozen] = bet
  end

  def lowhigh(lowhigh, bet)
    @lowhighs[lowhigh] = bet
  end

  def count
    @singles.values.sum + @colors.values.sum + @dozens.values.sum + @lowhighs.values.sum
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

    # lowhighs
    reward += begin
      bet.lowhighs[result.lowhigh] * 2
    rescue StandardError
      0
    end

    # dozens
    reward += begin
      bet.dozens[result.dozen] * 3
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
  # 何回連続で出たらbetし始めるか
  CONTINUOUS_COUNT = 6

  def initialize(account, roulette = nil)
    @account = account
    @roulette = roulette
  end

  # @params Bet
  # @return Bet
  def calculate(bet)
    # skip to collect data
    return bet if @roulette.histories.count < 10

    last_color = @roulette.histories[-1].color

    continuous = 0

    index = 0
    while index != @roulette.histories.count
      index -= 1
      next if @roulette.histories[index].color.nil? # 0を無視しないとbetが途中で止まってしまう

      if @roulette.histories[index].color == last_color
        continuous += 1
      else
        break
      end
    end

    return bet if continuous < CONTINUOUS_COUNT

    # マーチンゲール法
    bet_price = 2**(continuous - CONTINUOUS_COUNT)

    bet.color(Roulette.the_other_color(last_color), bet_price)

    @account.minus(bet_price)

    bet
  end
end

class HistoryLowHighDecision
  # 何回連続で出たらbetし始めるか
  CONTINUOUS_COUNT = 6 # 0.9921875

  def initialize(account, roulette = nil)
    @account = account
    @roulette = roulette
  end

  # @params Bet
  # @return Bet
  def calculate(bet)
    # skip to collect data
    return bet if @roulette.histories.count < 10

    last_lowhigh = @roulette.histories[-1].lowhigh

    continuous = 0

    index = 0
    while index != @roulette.histories.count
      index -= 1
      next if @roulette.histories[index].lowhigh.nil? # 0を無視しないとbetが途中で止まってしまう

      if @roulette.histories[index].lowhigh == last_lowhigh
        continuous += 1
      else
        break
      end
    end

    return bet if continuous < CONTINUOUS_COUNT

    # マーチンゲール法
    bet_price = 2**(continuous - CONTINUOUS_COUNT)

    if last_lowhigh == Roulette::LOW
      bet.lowhigh(Roulette::HIGH, bet_price)
      @account.minus(bet_price)
    elsif last_lowhigh == Roulette::LOW
      bet.lowhigh(Roulette::LOW, bet_price)
      @account.minus(bet_price)
    end

    bet
  end
end

class HistoryDozenDecision
  # 何回連続で出たらbetし始めるか
  CONTINUOUS_COUNT = 4 # 0.99588477

  def initialize(account, roulette = nil)
    @account = account
    @roulette = roulette
  end

  # @params Bet
  # @return Bet
  def calculate(bet)
    # skip to collect data
    return bet if @roulette.histories.count < 10

    last_dozen = @roulette.histories[-1].dozen

    continuous = 0

    index = 0
    while index != @roulette.histories.count
      index -= 1
      next if @roulette.histories[index].dozen.nil? # 0を無視しないとbetが途中で止まってしまう

      if @roulette.histories[index].dozen == last_dozen
        continuous += 1
      else
        break
      end
    end

    return bet if continuous < CONTINUOUS_COUNT

    # マーチンゲール法
    bet_price = 3**(continuous - CONTINUOUS_COUNT)

    if last_dozen != Roulette::DOZEN_1
      bet.dozen(Roulette::DOZEN_1, bet_price)
      @account.minus(bet_price)
    end
    if last_dozen != Roulette::DOZEN_2
      bet.dozen(Roulette::DOZEN_2, bet_price)
      @account.minus(bet_price)
    end
    if last_dozen != Roulette::DOZEN_3
      bet.dozen(Roulette::DOZEN_3, bet_price)
      @account.minus(bet_price)
    end

    bet
  end
end

class Record
  attr_reader :current_credit, :diff

  def initialize(current_credit, diff)
    @current_credit = current_credit
    @diff = diff
  end
end

class Account
  attr_reader :credit, :records, :min, :max

  def initialize(credit)
    @credit = @min = @max = credit
    @records = []
  end

  def plus(number)
    @records << Record.new(@credit, number)

    @credit += number

    calculate_statistics
  end

  def minus(number)
    raise "credit will be negative value. credit: #{@credit}, number: #{number}" if (@credit - number) < 0

    @records << Record.new(@credit, number)

    @credit -= number

    calculate_statistics
  end

  # @see https://www.oanda.jp/lab-education/blog_30strategy/4345/
  def calculate_statistics
    @min = [@min, @credit].min
    @max = [@max, @credit].max
  end
end

require 'logger'

class Logger
  @@logger = Logger.new(STDOUT)
  def self.getLogger
    @@logger
  end
end

class Player
  def initialize
    @bet_count = 0
    @win = @lose = 0
    @draw_count = 10_000 # (12 hours * 60 minutes) / 2 minutes each = 360
    @initial_credit = 500

    @account = Account.new(@initial_credit)
    @roulette = Roulette.new
  end

  def draw
    @draw_count.times do |draw_count|
      Logger.getLogger.debug("draw count: #{draw_count}")

      begin
        bet = Bet.new
        bet = HistoryColorDecision.new(@account, @roulette).calculate(bet)
        bet = HistoryDozenDecision.new(@account, @roulette).calculate(bet)
        bet = HistoryLowHighDecision.new(@account, @roulette).calculate(bet)

        Logger.getLogger.debug(bet) if bet.count.positive?
      rescue StandardError
        stats
        raise
      end

      # draw
      result = @roulette.draw

      Logger.getLogger.info(result)

      # skip reward calculation if no bet
      next unless bet.count.positive?

      @bet_count += 1

      reward = Reward.calculate(bet, result)

      Logger.getLogger.debug("reward: #{reward}")

      @account.plus(reward)

      Logger.getLogger.debug("account balance: #{@account.credit}")

      if reward.positive?
        @win += 1
      else
        @lose += 1
      end
    end

    stats
  end

  def stats
    puts 'Result distribution:'
    @roulette.histories.map(&:number).group_by(&:itself).map { |k, v| [k, v.size] }.to_h.sort.each do |k, v|
      puts format('%2d', k) + ': ' + ('*' * (v / 10)) + " #{v}"
    end
    puts 'Credit history'
    @account.records.each_with_index do |record, index|
      puts format('%4d', index) + ': ' + ('*' * (record.current_credit / 10)) + " #{record.current_credit}"
    end
    puts "Draw: #{@draw_count}"
    puts "Bet count: #{@bet_count}"
    puts "Bet ratio: #{(@bet_count.quo(@draw_count).to_f * 100).round(3)}%"
    puts "Credit: #{@account.credit}"
    puts "Absolute Drawdown: #{(@account.min.quo(@account.credit).to_f * 100).round(3)}%"
    puts "PL(%): #{((@account.credit.quo(@initial_credit).to_f - 1) * 100).round(3)}%"
    puts "Win: #{@win}"
    puts "Lose: #{@lose}"
    puts "Won(%): #{(@win.quo(@win + @lose).to_f * 100).round(3)} %"
  end
end

Player.new.draw
