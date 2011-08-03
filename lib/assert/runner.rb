module Assert
  class Runner

    # a Runner runs a suite of tests.

    attr_reader :time

    def initialize(suite, opts={})
      raise ArgumentError if !suite.kind_of?(Suite)
      @suite = suite
      @time = 0
    end

    def run(*args)
      benchmark do
        # TODO: parallel running
        tests_to_run(*args).each {|test| test.run}
      end if count(:tests) > 0
      count(:failed) + count(:errored)
    end

    def count(type)
      @suite.count(type)
    end

    protected

    def benchmark
      start = Time.now
      yield if block_given?
      @time = Time.now - start
    end

    def tests_to_run(*args)
      # run tests in a randomized order
      tests = @suite.contexts
      max = tests.size
      tests.sort.sort_by { rand max }
    end

    def seed
      srand
      seed = srand % 0xFFFF
      srand seed
    end

  end

end
