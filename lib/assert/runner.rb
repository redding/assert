require 'assert/config_helpers'
require 'assert/suite'
require 'assert/view'

module Assert

  class Runner
    include Assert::ConfigHelpers

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def runner; self; end

    def run
      self.on_start

      if self.single_test?
        self.view.print "Running test: #{self.single_test_file_line}"
      elsif self.tests_to_run?
        self.view.print "Running tests in random order"
      end
      if self.tests_to_run?
        self.view.puts ", seeded with \"#{self.runner_seed}\""
      end

      begin
        self.suite.start_time = Time.now
        self.suite.setups.each(&:call)
        self.on_run_tests(tests_to_run.tap{ self.suite.clear_tests_to_run }) do |ttr|
          ttr.delete_if do |test|
            test_data = test # TODO: test.data (?)

            self.before_test_run(test_data)
            test.run do |result|
              self.on_result(result) # TODO: result.data (?)
            end
            self.after_test_run(test_data)

            # always delete `test` from `tests_to_run` since it has been run
            true
          end
        end
        self.suite.teardowns.each(&:call)
        self.suite.end_time = Time.now
      rescue Interrupt => err
        self.on_interrupt(err)
        raise(err)
      end

      (self.fail_result_count + self.error_result_count).tap{ self.on_finish }
    end

    # Callbacks

    # override callback handlers to do special behavior during the test run.

    def before_load(test_files); end
    def after_load;              end

    def on_start
      self.suite.on_start
      self.view.on_start
    end

    def on_run_tests(tests_to_run)
      # TODO: setup IO pipes for each callback; fork

      # if in fork...
      self.on_tests_to_run(tests_to_run)

      # else, TODO: listen on callback pipes for data to process
    end

    def on_test(test)
    end

    def before_test_run(test_data)
      self.suite.before_test(test_data)
      self.view.before_test(test_data)
    end

    def on_result(result_data)
      self.suite.on_result(result_data)
      self.view.on_result(result_data)
    end

    def after_test_run(test_data)
      self.suite.after_test(test_data)
      self.view.after_test(test_data)
    end

    def on_finish
      self.view.on_finish
      self.suite.on_finish
    end

    def on_interrupt(err)
      self.suite.on_interrupt(err)
      self.view.on_interrupt(err)
    end

    private

    def tests_to_run
      srand self.runner_seed
      if self.single_test?
        [self.suite.find_test_to_run(self.single_test_file_line)].compact
      else
        self.suite.sorted_tests_to_run{ rand self.tests_to_run_count }
      end
    end

  end

end
