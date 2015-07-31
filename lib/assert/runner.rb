require 'assert/config_helpers'
require 'assert/suite'

module Assert

  class Runner
    include Assert::ConfigHelpers

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def run
      suite, view = @config.suite, @config.view
      raise ArgumentError if !suite.kind_of?(Suite)
      if tests?
        view.puts "Running tests in random order, seeded with \"#{runner_seed}\""
      end
      view.fire(:on_start)

      begin
        suite.setup

        suite.start_time = Time.now
        tests_to_run(suite).each do |test|
          view.fire(:before_test, test)
          test.run{ |result| view.fire(:on_result, result) }
          view.fire(:after_test, test)
        end
        suite.end_time = Time.now

        suite.teardown
      rescue Interrupt => err
        view.fire(:on_interrupt, err)
        raise(err)
      end

      view.fire(:on_finish)
      suite.count(:failed) + suite.count(:errored)
    end

    private

    def tests_to_run(suite)
      srand self.config.runner_seed
      suite.tests.sort.sort_by{ rand suite.tests.size }
    end

  end

end
