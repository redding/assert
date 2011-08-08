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

    def layout(runner)
      self.puts(:intro)

      if count(:tests) > 0
        # yield the output IO to the runner so it can add any result output
        runner.call(@out) if runner
        #self.puts(:details)
        #self.puts(:summary)
      end

      self.puts(:outro)
    end

    # override these parts or define you own to create custom output
    def intro; nil; end
    def details; nil; end
    def summary; nil; end
    def outro; nil; end

    def intro
      "Loaded suite (" +
        count(:tests).to_s + " tests, " +
        count(:assertions).to_s + " assertions)"
    end

    def outro
      "\n" +
        count(:tests).to_s + " tests running " +
        count(:assertions).to_s + " assertions (" +
        count(:passed).to_s + " passed, " +
        count(:failed).to_s + " failed, " +
        count(:skipped).to_s + " skipped, " +
        count(:errored).to_s + " errored)\n" +
        "(" + run_time.to_s + "seconds)"
    end

  end
end
