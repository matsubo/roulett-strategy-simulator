require 'logger'
require 'singleton'

module Roulette
  module Simulator
    class SingletonLogger < Logger
      include Singleton

      # Per-spin detail is logged at DEBUG; set LOG_LEVEL=debug to see it.
      def initialize
        super($stderr, level: ENV.fetch('LOG_LEVEL', 'warn'))
      end
    end
  end
end
