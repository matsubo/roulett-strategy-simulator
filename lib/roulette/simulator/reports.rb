require_relative 'statistics'

module Roulette
  module Simulator
    # Rendering of a Statistics: Reports::Html writes report.html.
    module Reports
      BET_LABELS = {
        color: 'Red / black',
        lowhigh: 'Low / high',
        evenodd: 'Even / odd',
        dozen: 'Dozen',
        column: 'Column',
        single: 'Straight up'
      }.freeze

      module_function

      def percent(fraction, digits = 1)
        fraction.nil? ? '-' : format("%.#{digits}f%%", fraction * 100)
      end

      def amount(value)
        return '-' if value.nil?

        text = value.is_a?(Float) ? format('%.1f', value).delete_suffix('.0') : value.to_s
        text.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
      end

      def signed_amount(value)
        value.positive? ? "+#{amount(value)}" : amount(value)
      end
    end
  end
end

require_relative 'reports/html'
