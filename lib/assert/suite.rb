require 'assert/config_helpers'
require 'assert/test'

module Assert

  class Suite
    include Assert::ConfigHelpers

    TEST_METHOD_REGEX = /^test./.freeze

    # TODO: improve this comment
    # A suite is a set of tests to run.  When a test class subclasses
    # the Context class, that test class is pushed to the suite.

    attr_reader :config, :test_methods, :setups, :teardowns
    attr_accessor :start_time, :end_time

    def initialize(config)
      @config       = config
      @test_methods = []
      @setups       = []
      @teardowns    = []
      @start_time   = Time.now
      @end_time     = @start_time
    end

    def suite; self; end

    def setup(&block)
      self.setups << (block || proc{})
    end
    alias_method :startup, :setup

    def teardown(&block)
      self.teardowns << (block || proc{})
    end
    alias_method :shutdown, :teardown

    def tests_to_run?;                      end
    def tests_to_run_count;                 end
    def clear_tests_to_run;                 end
    def find_test_to_run(file_line);        end
    def sorted_tests_to_run(&sort_by_proc); end

    def run_time
      @end_time - @start_time
    end

    def test_rate
      get_rate(self.test_count, self.run_time)
    end

    def result_rate
      get_rate(self.result_count, self.run_time)
    end

    def test_count;          end
    def result_count;        end
    def pass_result_count;   end
    def fail_result_count;   end
    def error_result_count;  end
    def skip_result_count;   end
    def ignore_result_count; end

    # Callbacks

    # define callback handlers to do special behavior during the test run.  These
    # will be called by the test runner

    def before_load(test_files); end
    def on_test(test);           end
    def after_load;              end
    def on_start;                end
    def before_test(test);       end
    def on_result(result);       end
    def after_test(test);        end
    def on_finish;               end
    def on_interrupt(err);       end

    def inspect
      "#<#{self.class}:#{'0x0%x' % (object_id << 1)}"\
      " test_count=#{self.test_count.inspect}"\
      " result_count=#{self.result_count.inspect}>"
    end

  end

end
