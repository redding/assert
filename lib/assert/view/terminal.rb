require 'assert/view/base'
require 'assert/result'

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

    attr_reader :result_styles

    def initialize(suite, output_io, opts={})
      super(suite, output_io)
      @result_styles = {
        :passed  => :green,
        :failed  => :red,
        :ignored  => :magenta,
        :skipped => :cyan,
        :errored  => :yellow
      }.merge(opts[:result_styles] || {})
    end

    def render(*args, &block)
      self.io_print(self.load_stmt)

      if count(:tests) > 0
        block.call if block
        self.io_puts(:detailed_results)
      end

      self.io_puts(:results_stmt)
    end

    def print_result(result)
      self.io_print(result_io_msg(result.abbrev, result.to_sym))
    end

    protected

    def load_stmt
      tplur = (tcount = count(:tests)) == 1 ? "test": "tests"
      "\nLoaded suite (#{tcount} #{tplur})  "
    end

    def detailed_results
      @suite.tests
      "\n\n" + @suite.ordered_results.reverse.collect do |result|
        result_io_msg(result.to_s, result.to_sym) if show_result_details?(result)
      end.compact.join("\n\n")
    end

    def results_stmt
      rplur = (rcount = count(:results)) == 1 ? "result" : "results"
      [ "\n",
        "#{rcount} test #{rplur}: ", results_breakdown, "\n\n",
        "(#{run_time} seconds)"
      ].join('')
    end

    def results_breakdown
      if count(:passed) == count(:tests)
        result_io_msg("all passed", :passed)
      else
        [:passed, :failed, :ignored, :skipped, :errored].inject([]) do |results, result_sym|
          results << (if count(result_sym) > 0
            result_io_msg("#{count(result_sym)} #{result_sym}", result_sym)
          end)
        end.compact.join(', ')
      end
    end

    def result_io_msg(msg, result_sym)
      io_msg(msg, :term_styles => self.result_styles[result_sym])
    end

    def io_msg(msg, opts={})
      val = super
      if color = term_style(*opts[:term_styles])
        val = color + val + term_style(:reset)
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
