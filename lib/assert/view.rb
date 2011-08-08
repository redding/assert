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

    def puts(msg)
      if msg && self.respond_to?(msg) && (val=self.send(msg))
        @out.puts(val)
      end
    end
    def print(msg)
      if msg && self.respond_to?(msg) && (val=self.send(msg))
        @out.print(val)
      end
    end

    def run_time(format='%.6f')
      format % @suite.run_time
    end

    def count(type)
      @suite.count(type)
    end

  end

  class Basic < Base

    def render(*args, &runner)
      self.puts(:intro)

      if count(:tests) > 0
        # yield the output IO to the runner so it can add any result output
        runner.call(@out) if runner
        #self.puts(:details)
        #self.puts(:summary)
      end

      self.puts(:outro)
    end

    def intro
      "Loaded suite (" +
        count(:tests).to_s + " tests, " +
        count(:assertions).to_s + " assertions)"
    end

    def outro
      [ "\n",
        test_assert_count_oneliner, ': ',
        results_oneliner, ' ',
        "(#{run_time} seconds)"
      ].join('')
    end

    protected

    def test_assert_count_oneliner
      tplur = (tcount = count(:tests)) == 1 ? "test": "tests"
      aplur = (acount = count(:assertions)) == 1 ? "assertion" : "assertions"

      [acount, aplur, "(#{tcount} #{tplur})"].join(' ')
    end

    def results_oneliner
      if count(:passed) == count(:tests)
        "all passed"
      else
        [:passed, :failed, :skipped, :errored].inject([]) do |parts, part|
          parts << count(part) > 0 ? "#{count(part)} #{part}" : nil
        end.join(', ')
      end
    end



  end
end
