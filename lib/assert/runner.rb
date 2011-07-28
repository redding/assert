module Assert
  class Runner

    # a Runner runs a suite of tests.

    def initialize(suite)
      raise ArgumentError if !suite.kind_of?(Suite)
      @suite = suite
      @run_time = 0
    end

    def run
      # don't do anything if there aren't any tests to run
      return 0 if count(:tests) == 0

      Assert.puts run_preamble

      benchmark do
        suite.run
      end

      # TODO: result_details
      # TODO: result_summary

      Assert.puts run_postamble

      # the sum of the failed and errored counts serves as the return code
      count(:failed) + count(:errored)
    end

    def time(format='%.6f')
      format % @run_time
    end

    def count(type)
      @suite.count(type)
    end

    protected

    def benchmark
      start = Time.now
      yield if block_given?
      @run_time = Time.now - start
    end

    # TODO: for randomizing test run order
    # def seed
    #   srand
    #   seed = srand % 0xFFFF
    #   srand seed
    # end

    def run_preamble
      "Loaded suite (" +
        count(:tests) + " tests, " +
        count(:assertions) + " assertions)"
    end

    def run_postamble
      "\n" +
        count(:tests) + " tests running " +
        count(:assertions) + " assertions (" +
        count(:passed) + " passed, " +
        count(:failed) + " failed, " +
        count(:skipped) + " skipped, " +
        count(:errored) + " errored)\n" +
        "(" + time + "seconds)"
    end

  end
end