require 'assert/view/base'
require 'assert/result'

require 'assert/options'

module Assert::View

  class Terminal < Base

    TERM_STYLES = {
      :reset     => 0,
      :bold      => 1,
      :underline => 4,
      :black     => 30,
      :red       => 31,
      :green     => 32,
      :yellow    => 33,
      :blue      => 34,
      :magenta   => 35,
      :cyan      => 36,
      :white     => 37,
      :bgblack   => 40,
      :bgred     => 41,
      :bggreen   => 42,
      :bgyellow  => 43,
      :bgblue    => 44,
      :bgmagenta => 45,
      :bgcyan    => 46,
      :bgwhite   => 47
    }

    include Assert::Options
    options do
      default_styled          false
      default_passed_abbrev   '.'
      default_failed_abbrev   'F'
      default_ignored_abbrev  'I'
      default_skipped_abbrev  'S'
      default_errored_abbrev  'E'
      default_passed_styles   :green
      default_failed_styles   :red
      default_ignored_styles  :magenta
      default_skipped_styles  :cyan
      default_errored_styles  :yellow
    end

    def render(*args, &block)
      self.io_print(:load_stmt)

      if count(:tests) > 0
        block.call if block
        self.io_puts(:detailed_results)
      end

      self.io_puts(:results_stmt)
    end

    def print_result(result)
      sym = result.to_sym
      self.io_print(result_io_msg(self.options.send("#{sym}_abbrev"), sym))
    end

    protected

    def load_stmt
      tplur = (tcount = count(:tests)) == 1 ? "test": "tests"
      "\nLoaded suite (#{tcount} #{tplur})  "
    end

    def detailed_results
      @suite.tests
      details = @suite.ordered_results.reverse.collect do |result|
        result_io_msg(result.to_s, result.to_sym) if show_result_details?(result)
      end.compact
      "\n\n" + details.join("\n\n") if !details.empty?
    end

    def results_stmt
      rplur = (rcount = count(:results)) == 1 ? "result" : "results"
      [ "\n",
        "#{rcount} test #{rplur}: ", results_breakdown, "\n\n",
        "(#{run_time} seconds)"
      ].join('')
    end

    def results_breakdown
      if count(:passed) == count(:results)
        stmnt = if count(:results) < 1
          "uhh..."
        elsif count(:results) == 1
          "it passed"
        else
          "all passed"
        end
        result_io_msg(stmnt, :passed)
      else
        breakdowns = [:passed, :failed, :ignored, :skipped, :errored]
        breakdowns = breakdowns.inject([]) do |results, result_sym|
          results << (if count(result_sym) > 0
            result_io_msg("#{count(result_sym)} #{result_sym}", result_sym)
          end)
        end.compact
        if breakdowns.size < 2
          breakdowns.join('')
        elsif breakdowns.size == 2
          breakdowns.join(" and ")
        else
          [breakdowns[0..-2].join(", "), breakdowns.last].join(", and ")
        end
      end
    end

    def result_io_msg(msg, result_sym)
      term_styles = if self.options.styled
        self.options.send("#{result_sym}_styles")
      end
      io_msg(msg, :term_styles => term_styles)
    end

    def io_msg(msg, opts={})
      val = super
      if !(style = term_style(*opts[:term_styles])).empty?
        val = style + val + term_style(:reset)
      else
        val
      end
    end

    def term_style(*styles)
      styles.collect do |style|
        TERM_STYLES.include?(style) ? "\e[#{TERM_STYLES[style]}m" : nil
      end.join('')
    end

    def show_result_details?(result)
      ([:failed, :errored].include?(result.to_sym)) ||
      ([:skipped, :ignored].include?(result.to_sym) && result.message)
    end

  end

end
