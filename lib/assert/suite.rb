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

    def tests_to_run;       end
    def tests_to_run?;      end
    def tests_to_run_count; end
    def clear_tests_to_run; end

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

    # Test data

    def ordered_tests;              end
    def reversed_tests;             end
    def ordered_tests_by_run_time;  end
    def reversed_tests_by_run_time; end

    # Result data

    def ordered_results;           end
    def reversed_results;          end
    def ordered_results_for_dump;  end
    def reversed_results_for_dump; end

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

    private

    def get_rate(count, time)
      time == 0 ? 0.0 : (count.to_f / time.to_f)
    end

  end

end
