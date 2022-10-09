require 'bundler'

Bundler.require(:default)

require './lib/roulette/simulator/bet_data'
require './lib/roulette/simulator/result'
require './lib/roulette/simulator/table'
require './lib/roulette/simulator/reward'
require './lib/roulette/simulator/singleton_logger'
require './lib/roulette/simulator/decisions'
require './lib/roulette/simulator/record'
require './lib/roulette/simulator/account'
require './lib/roulette/simulator/player'
require './lib/roulette/simulator/exception/balacne_is_not_enough'

class PlaySuite

  def initialize
    @stats = {
      bankrupt: 0
    }
    @days = 365
      @initial_credit = 250

  end

  def execute

    draw_request_count = 360 # (12 hours * 60 minutes) / 2 minutes each = 360

    random = Random.new(ENV.fetch('seed', rand(10000000)))


    account_result = []
    @days.times do |i|
      account = Roulette::Simulator::Account.new(@initial_credit)
      begin
        play(account, draw_request_count, random)
      rescue Roulette::Simulator::Exception::BalanceIsNotEnough => e
        Roulette::Simulator::SingletonLogger.instance.debug(e.to_s)
        @stats[:bankrupt] += 1
        next
      end
      account_result << account.clone
    end

    showSuiteStats

    # for gnuplot data
    Gnuplot.open do |gp|

      # memo: size 500,2500
      gp << 'set terminal png enhanced truecolor' << "\n"
      gp << 'set output "result.png"' << "\n"

      Gnuplot::Multiplot.new(gp, layout: [1, 1]) do |mp|

        Gnuplot::Plot.new(mp) do |plot|
          account_result.each do |account|

            plot.title  "Credit balance (#{draw_request_count} draws x #{@days} times)"
            plot.xlabel 'Draw count'
            plot.ylabel 'Credit balance'

            x = [0]
            y = [@initial_credit]

            account.records.each do |record|
              x << record.draw_count
              y << record.current_credit
            end

            plot.data << Gnuplot::DataSet.new([x, y]) do |ds|
              ds.with = 'linespoints'
              ds.notitle
            end
          end
        end
      end
    end
  end

  def play(account, draw_request_count, random)

    table = Roulette::Simulator::Table.new(random)

    player = Roulette::Simulator::Player.new(table, account, draw_request_count)
    player.draw
    stats = player.stats

    puts "Draw request: #{draw_request_count}"
    puts "Draw executed: #{stats[:draw_count]}"
    puts "Max bet: #{stats[:max_bet]}"
    puts "Bet count: #{stats[:bet_count]}"
    puts "Bet ratio: #{(stats[:bet_count].quo(stats[:draw_count]).to_f * 100).round(3)}%"
    puts "Credit: #{account.credit}"
    puts "Absolute Drawdown: #{(account.min.quo(account.credit).to_f * 100).round(3)}%" unless account.credit.zero?
    puts "PL(%): #{((account.credit.quo(@initial_credit).to_f - 1) * 100).round(3)}%"
    puts "Win: #{stats[:win]}"
    puts "Lose: #{stats[:lose]}"
    if (stats[:win] + stats[:lose]).positive?
      puts "Won(%): #{(stats[:win].quo(stats[:win] + stats[:lose]).to_f * 100).round(3)} %"
    end
    puts "Seed: #{random.seed}"

  end

  def showSuiteStats
    puts "Bankrupt: #{@stats[:bankrupt]}"
    puts "Bankrupt rate: #{(@stats[:bankrupt].quo(@days).to_f * 100).round(3)}%"
  end
end

PlaySuite.new.execute
