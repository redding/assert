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




  class BasicTerminal < Base

    TERM_COLORS = {
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

    def render(*args, &runner)
      self.io_puts(self.intro)

      if count(:tests) > 0
        # yield the output IO to the runner so it can add any result output
        runner.call(@out) if runner
        #self.io_puts(:details)
        #self.io_puts(:summary)
      end

      self.io_puts(:outro)
    end

    def intro
      tplur = (tcount = count(:tests)) == 1 ? "test": "tests"
      "\nLoaded suite (#{tcount} #{tplur})"
    end

    def outro
      aplur = (acount = count(:assertions)) == 1 ? "assertion" : "assertions"
      [ "\n",
        "#{acount} #{aplur}: ", results_breakdown, "\n\n",
        "(#{run_time} seconds)"
      ].join('')
    end

    protected

    def results_breakdown
      if count(:passed) == count(:tests)
        io_msg("all passed", :term_color => :green)
      else
        [ [:passed, :green],
          [:failed, :red],
          [:skipped, :cyan],
          [:errored, :yellow]
        ].inject([]) do |parts, p_c|
          parts << (if count(p_c[0]) > 0
            io_msg("#{count(p_c[0])} #{p_c[0]}", :term_color => p_c[1])
          end)
        end.compact.join(', ')
      end
    end

    def io_msg(msg, opts={})
      val = super
      if color = term_color(opts[:term_color])
        val = color + val + term_color(:reset)
      else
        val
      end
    end

    def term_color(code)
      TERM_COLORS.include?(code) ? "\e[#{TERM_COLORS[code]}m" : nil
    end

  end



end
