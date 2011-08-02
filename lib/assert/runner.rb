module Assert
  class Runner

    # a Runner runs a suite of tests.

    def initialize(suite, opts={})
      raise ArgumentError if !suite.kind_of?(Suite)
      @suite = suite
      @run_time = 0
    end

    def run(*args)
      # don't do anything if there aren't any tests to run
      benchmark do
        # TODO: parallel running
        tests_to_run(*args).each {|test| test.run}
      end if count(:tests) > 0
      count(:failed) + count(:errored)
    end

    def count(type)
      @suite.count(type)
    end

    def time(format='%.6f')
      format % @run_time
    end

    protected

    def benchmark
      start = Time.now
      yield if block_given?
      @run_time = Time.now - start
    end

    def tests_to_run(*args)
      # TODO: randomize
      @suite.contexts
    end

    # TODO: for randomizing test run order
    # def seed
    #   srand
    #   seed = srand % 0xFFFF
    #   srand seed
    # end

  end

end
