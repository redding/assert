module Assert
  class Runner

    # a Runner runs a suite of tests.

    def initialize(suite, view)
      raise ArgumentError if !suite.kind_of?(Suite)
      @suite = suite
      @view = view
    end

    def run(render=true)
      @suite.setup

      if render
        # render the view, passing it a callback block to run the test suite
        @view.render do
          benchmark { run_suite }
        end
      else
        benchmark { run_suite }
      end

      @suite.teardown
      count(:failed) + count(:errored)
    end

    def count(type)
      @suite.count(type)
    end

    protected

    def tests_to_run
      # order tests randomly
      tests = @suite.tests
      srand @suite.runner_seed
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
      tests_to_run.each {|test| test.run(@view)}
    end

  end

end
