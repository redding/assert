module Assert

  class Runner

    # a Runner runs a suite of tests.

    def initialize(suite, view)
      raise ArgumentError if !suite.kind_of?(Suite)
      @suite, @view = suite, view
    end

    def run
      @view.fire(:on_start)
      @suite.setup

      benchmark { run_suite }

      @suite.teardown
      @view.fire(:on_finish)

      count(:failed) + count(:errored)
    end

    def count(type)
      @suite.count(type)
    end

    protected

    def tests_to_run
      # order tests randomly
      tests = @suite.tests
      srand Assert.config.runner_seed # TODO: secure random??
      tests.sort.sort_by { rand tests.size }
    end

    private

    def benchmark
      @suite.start_time = Time.now
      yield if block_given?
      @suite.end_time = Time.now
    end

    def run_suite
      # TODO: parallel running
      tests_to_run.each do |test|
        @view.fire(:before_test, test)
        test.run {|result| @view.fire(:on_result, result)}
        @view.fire(:after_test, test)
      end
    end

  end

end
