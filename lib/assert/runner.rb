module Assert

  class Runner

    # Runner runs a suite of tests.

    def run(suite, view)
      raise ArgumentError if !suite.kind_of?(Suite)

      view.fire(:on_start)
      suite.setup

      suite.start_time = Time.now
      # TODO: parallel running
      tests_to_run(suite).each do |test|
        view.fire(:before_test, test)
        test.run{ |result| view.fire(:on_result, result) }
        view.fire(:after_test, test)
      end
      suite.end_time = Time.now

      suite.teardown
      view.fire(:on_finish)

      suite.count(:failed) + suite.count(:errored)
    end

    protected

    def tests_to_run(suite)
      srand Assert.config.runner_seed # TODO: secure random??
      suite.tests.sort.sort_by { rand suite.tests.size }
    end

  end

end
