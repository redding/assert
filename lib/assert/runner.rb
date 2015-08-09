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
      view.on_start

      begin
        suite.setups.each(&:call)

        suite.start_time = Time.now
        tests_to_run(suite).each do |test|
          view.before_test(test)
          test.run{ |result| view.on_result(result) }
          view.after_test(test)
        end
        suite.end_time = Time.now

        suite.teardowns.each(&:call)
      rescue Interrupt => err
        view.on_interrupt(err)
        raise(err)
      end

      view.on_finish
      suite.count(:failed) + suite.count(:errored)
    end

    private

    def tests_to_run(suite)
      srand self.config.runner_seed
      suite.tests.sort.sort_by{ rand suite.tests.size }
    end

  end

end
