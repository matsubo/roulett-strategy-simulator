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

Roulette::Simulator::Player.new.draw
