 module Assert::View



  class Base

    # a Runner runs a suite of tests.

    def initialize(suite, output_io)
      @suite = suite
      @out = output_io
    end

    # override this to define how a view calls the runner and renders its results
    def render(*args, &runner)
      raise NotImplementedError
    end

    protected

    def io_puts(msg, opts={})
      @out.puts(io_msg(msg, opts={}))
    end
    def io_print(msg, opts={})
      @out.print(io_msg(msg, opts={}))
    end
    def io_msg(msg, opts={})
      val = if msg.kind_of?(::Symbol) && self.respond_to?(msg)
        self.send(msg)
      else
        msg.to_s
      end

      val
    end

    def run_time(format='%.6f')
      format % @suite.run_time
    end

    def count(type)
      @suite.count(type)
    end

  end




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
        :skipped => :cyan,
        :errored  => :yellow
      }.merge(opts[:result_styles] || {})
    end

    def render(*args, &runner)
      self.io_puts(self.load_stmt)

      if count(:tests) > 0
        # yield the output IO to the runner so it can add any result output
        runner.call(@out) if runner
        #self.io_puts(:details)
        #self.io_puts(:summary)
      end

      self.io_puts(:results_stmt)
    end

    protected

    def load_stmt
      tplur = (tcount = count(:tests)) == 1 ? "test": "tests"
      "\nLoaded suite (#{tcount} #{tplur})"
    end

    def results_stmt
      rplur = (rcount = count(:assertions)) == 1 ? "result" : "result"
      [ "\n",
        "#{rcount} #{rplur}: ", results_breakdown, "\n\n",
        "(#{run_time} seconds)"
      ].join('')
    end

    def results_breakdown
      if count(:passed) == count(:tests)
        result_io_msg("all passed", :passed)
      else
        [:passed, :failed, :skipped, :errored].inject([]) do |results, result|
          results << (result_io_msg("#{count(result)} #{result}", result) if count(result) > 0)
        end.compact.join(', ')
      end
    end

    def result_io_msg(msg, result)
      io_msg(msg, :term_styles => self.result_styles[result])
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

  end



end
