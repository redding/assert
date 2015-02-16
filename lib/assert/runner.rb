require 'assert/suite'

module Assert

  class Runner

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def run(suite, view)
      raise ArgumentError if !suite.kind_of?(Suite)

      begin
        view.fire(:on_start)
        suite.setup

        suite.start_time = Time.now
        tests_to_run(suite).each do |test|
          view.fire(:before_test, test)
          test.run{ |result| view.fire(:on_result, result) }
          view.fire(:after_test, test)
        end
        suite.end_time = Time.now

        suite.teardown
        view.fire(:on_finish)
      rescue Interrupt => err
        view.fire(:on_interrupt, err)
        raise(err)
      end

      suite.count(:failed) + suite.count(:errored)
    end

    private

    def tests_to_run(suite)
      srand self.config.runner_seed
      suite.tests.sort.sort_by { rand suite.tests.size }
    end

  end

end
