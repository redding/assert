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
      self.suite.on_start
      self.view.on_start

      if self.single_test?
        self.view.puts "Running test: #{self.single_test_file_line}"
      elsif self.tests?
        self.view.puts "Running tests in random order, " \
                       "seeded with \"#{self.runner_seed}\""
      end

      begin
        self.suite.start_time = Time.now
        self.suite.setups.each(&:call)
        tests_to_run.each do |test|
          self.before_test(test)
          self.suite.before_test(test)
          self.view.before_test(test)
          test.run do |result|
            self.on_result(result)
            self.suite.on_result(result)
            self.view.on_result(result)
          end
          self.after_test(test)
          self.suite.after_test(test)
          self.view.after_test(test)
        end
        self.suite.teardowns.each(&:call)
        self.suite.end_time = Time.now
      rescue Interrupt => err
        self.on_interrupt(err)
        self.suite.on_interrupt(err)
        self.view.on_interrupt(err)
        raise(err)
      end

      (self.suite.count(:fail) + self.suite.count(:error)).tap do
        self.view.on_finish
        self.suite.on_finish
        self.on_finish
      end
    end

    # Callbacks

    # define callback handlers to do special behavior during the test run. These
    # will be called by the test runner

    def before_load(test_files); end
    def after_load;              end
    def on_start;                end
    def before_test(test);       end
    def on_result(result);       end
    def after_test(test);        end
    def on_finish;               end
    def on_interrupt(err);       end

    private

    def tests_to_run
      if self.single_test?
        [ self.suite.tests.find{ |t| t.file_line == self.single_test_file_line }
        ].compact
      else
        srand self.runner_seed
        self.suite.tests.sort.sort_by{ rand self.suite.tests.size }
      end
    end

  end

end
