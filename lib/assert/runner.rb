module Assert
  class Runner

    # a Runner runs a suite of tests.

    def initialize(suite, opts={})
      raise ArgumentError if !suite.kind_of?(Suite)
      @suite = suite
      @out = opts[:output]
      @run_time = 0
    end

    def run
      # don't do anything if there aren't any tests to run
      if count(:tests) > 0
        self.puts run_preamble

        benchmark do
          suite.run
        end

        # TODO: result_details
        # TODO: result_summary
      end

      self.puts run_postamble

      # the sum of the failed and errored counts serves as the return code
      count(:failed) + count(:errored)
    end

    def time(format='%.6f')
      format % @run_time
    end

    def count(type)
      @suite.count(type)
    end

    def puts(msg="")
      @out.puts msg if @out && @out.respond_to?(:puts)
    end
    def print(msg="")
      @out.print msg if @out && @out.respond_to?(:print)
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
        count(:tests).to_s + " tests, " +
        count(:assertions).to_s + " assertions)"
    end

    def run_postamble
      "\n" +
        count(:tests).to_s + " tests running " +
        count(:assertions).to_s + " assertions (" +
        count(:passed).to_s + " passed, " +
        count(:failed).to_s + " failed, " +
        count(:skipped).to_s + " skipped, " +
        count(:errored).to_s + " errored)\n" +
        "(" + time.to_s + "seconds)"
    end

  end
end