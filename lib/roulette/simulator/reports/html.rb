require 'erb'
require 'json'
require 'time'

module Roulette
  module Simulator
    module Reports
      # Self-contained HTML report (charts load Chart.js and fonts from CDNs).
      class Html
        TEMPLATE = File.join(__dir__, 'report.html.erb')

        def initialize(statistics, seed:)
          @stats = statistics
          @seed = seed
        end

        def write(path)
          File.write(path, render)
          path
        end

        def render
          ERB.new(File.read(TEMPLATE), trim_mode: '-').result(binding)
        end

        private

        def kpis
          days = @stats.days
          drawdowns = @stats.drawdowns
          [
            ['Bankrupt days', Reports.percent(@stats.bankrupt_days.fdiv(days)), "#{@stats.bankrupt_days} of #{days} days", :loss],
            ['Profitable days', Reports.percent(@stats.profitable_days.fdiv(days)), "#{@stats.profitable_days} of #{days} days", :gain],
            ['Median final bankroll', Reports.amount(@stats.median_final_bankroll),
             "started at #{Reports.amount(@stats.initial_bankroll)}", nil],
            ['Mean profit per day', Reports.percent(@stats.mean_profit_rate), 'of the starting bankroll',
             @stats.mean_profit_rate.negative? ? :loss : :gain],
            ['Return to player', Reports.percent(@stats.return_to_player, 2),
             "#{Reports.amount(@stats.total.returned)} back on #{Reports.amount(@stats.total.staked)} staked", nil],
            ['Max drawdown', Reports.percent(Statistics.percentile(drawdowns, 50)),
             "median day · worst #{Reports.percent(drawdowns.max)}", :loss]
          ]
        end

        def day_rows
          @stats.outcomes.each_with_index.map do |outcome, index|
            final = outcome.final_bankroll
            {
              day: index + 1,
              final: final,
              profit: final - @stats.initial_bankroll,
              drawdown: outcome.max_drawdown,
              spins_played: outcome.spins_played,
              bankrupt_at: outcome.bankrupt_at,
              wagers: outcome.total.bets,
              win_rate: outcome.total.bets.zero? ? nil : outcome.total.wins.fdiv(outcome.total.bets),
              max_stake: outcome.total.max_stake
            }
          end
        end

        def bet_rows
          @stats.by_bet.map do |bet, tally|
            { key: bet, label: BET_LABELS.fetch(bet), bets: tally.bets, win_rate: tally.wins.fdiv(tally.bets),
              staked: tally.staked, returned: tally.returned, net: tally.net, max_stake: tally.max_stake,
              rtp: tally.returned.fdiv(tally.staked) }
          end
        end

        def chart_data
          {
            spins: @stats.spins,
            initial: @stats.initial_bankroll,
            bands: @stats.bankroll_bands.transform_keys { |pct| "p#{pct}" }
                         .transform_values { |values| values.map { |value| value.round(1) } },
            survival: @stats.survival.map { |share| (share * 100).round(2) },
            histogram: @stats.final_bankroll_histogram,
            bets: bet_rows.map { |row| row.slice(:label, :net) },
            days: day_rows.zip(@stats.outcomes).map do |row, outcome|
              row.slice(:day, :final, :drawdown, :bankrupt_at).merge(path: @stats.bankroll_path(outcome))
            end
          }
        end

        # JSON safe to embed inside a <script> element.
        def chart_json
          JSON.generate(chart_data).gsub('</', '<\/')
        end

        def h(text)
          ERB::Util.html_escape(text)
        end

        def generated_at
          Time.now.strftime('%Y-%m-%d %H:%M')
        end
      end
    end
  end
end
