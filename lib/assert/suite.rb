module Assert
  class Suite < ::SortedSet

    # A suite is the set contexts to run.  When a test class subclasses
    # the Context class, that klass is pushed to the suite.

    def initialize
      @run_time = 0
    end

    def run
      # don't do anything if there aren't any tests to run
      return 0 if count(:tests) == 0

      run_preamble
      benchmark do
        self.each {|context| context.run}
      end
      # TODO: result_details
      # TODO: result_summary
      run_postamble

      # the sum of the failed and errored counts serves as the return code
      count(:failed) + count(:errored)
    end

    protected

    def benchmark
      start = Time.now
      yield if block_given?
      @run_time = Time.now - start
    end

    def seed
      srand
      seed = srand % 0xFFFF
      srand seed
    end

    def run_seconds
      '%.6f' % @run_time
    end

    def count(type)
      case type
      when :tests
        0
      when :assertions
        0
      when :passed
        0
      when :failed
        0
      when :skipped
        0
      when :errored
        0
      end
    end

    def run_preamble
      Assert.puts "Loaded suite (" +
        count(:tests) + " tests, " +
        count(:assertions) + " assertions)"
    end

    def run_postamble
      Assert.puts "\n" +
        count(:tests) + " tests running " +
        count(:assertions) + " assertions (" +
        count(:passed) + " passed, " +
        count(:failed) + " failed, " +
        count(:skipped) + " skipped, " +
        count(:errored) + " errored)"
      Assert.puts "\n" +
        "(#{run_seconds} seconds)"
    end

  end
end