require 'logger'
require 'singleton'

module Roulette
  module Simulator
    class SingletonLogger < Logger
      include Singleton

      def initialize
        super(STDOUT, level: Logger::DEBUG)
      end
    end
  end
end
