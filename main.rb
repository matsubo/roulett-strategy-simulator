require 'bundler'

Bundler.require(:default)

require './lib/roulette/simulator/bet_data'
require './lib/roulette/simulator/result'
require './lib/roulette/simulator/table'
require './lib/roulette/simulator/reward'
require './lib/roulette/simulator/singleton_logger'
require './lib/roulette/simulator/decisions'
require './lib/roulette/simulator/account'
require './lib/roulette/simulator/outside_bet'
require './lib/roulette/simulator/streak_strategy'
require './lib/roulette/simulator/day_outcome'
require './lib/roulette/simulator/player'
require './lib/roulette/simulator/exception/balacne_is_not_enough'
require './lib/roulette/simulator/statistics'
require './lib/roulette/simulator/reports'

class PlaySuite
  DAYS = 100
  SPINS_PER_DAY = 360 # (12 hours * 60 minutes) / 2 minutes each = 360
  INITIAL_BANKROLL = 200
  REPORT_PATH = 'report.html'.freeze

  def execute
    seed = ENV.fetch('SEED', rand(10_000_000)).to_i
    random = Random.new(seed)

    outcomes = Array.new(DAYS) do
      table = Roulette::Simulator::Table.new(random)
      account = Roulette::Simulator::Account.new(INITIAL_BANKROLL)
      Roulette::Simulator::Player.new(table, account, SPINS_PER_DAY).play
    end

    statistics = Roulette::Simulator::Statistics.new(outcomes, spins: SPINS_PER_DAY, initial_bankroll: INITIAL_BANKROLL)
    Roulette::Simulator::Reports::Html.new(statistics, seed: seed).write(REPORT_PATH)
    puts "Report written to #{REPORT_PATH} (seed #{seed})"
  end
end

PlaySuite.new.execute
