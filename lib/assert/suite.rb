require 'assert/config_helpers'
require 'assert/test'

module Assert

  class Suite
    include Assert::ConfigHelpers

    TEST_METHOD_REGEX = /^test./.freeze

    # A suite is a set of tests to run.  When a test class subclasses
    # the Context class, that test class is pushed to the suite.

    attr_reader :config, :tests, :test_methods, :setups, :teardowns
    attr_accessor :start_time, :end_time

    def initialize(config)
      @config       = config
      @tests        = []
      @test_methods = []
      @setups       = []
      @teardowns    = []
      @start_time   = Time.now
      @end_time     = @start_time
    end

    def setup(&block)
      self.setups << (block || proc{})
    end
    alias_method :startup, :setup

    def teardown(&block)
      self.teardowns << (block || proc{})
    end
    alias_method :shutdown, :teardown

    def run_time
      @end_time - @start_time
    end

    def test_rate
      get_rate(self.test_count, self.run_time)
    end

    def result_rate
      get_rate(self.result_count, self.run_time)
    end

    def count(thing)
      if thing == :tests
        test_count
      elsif thing == :results
        result_count
      elsif thing == :pass   || thing == :passed
        result_count(:pass)
      elsif thing == :fail   || thing == :failed
        result_count(:fail)
      elsif thing == :error  || thing == :errored
        result_count(:error)
      elsif thing == :skip   || thing == :skipped
        result_count(:skip)
      elsif thing == :ignore || thing == :ignored
        result_count(:ignore)
      else
        0
      end
    end

    # Test Handling

    def ordered_tests;                      end
    def reversed_ordered_tests;             end
    def ordered_tests_by_run_time;          end
    def reversed_ordered_tests_by_run_time; end
    def test_count;                         end

    # Result Handling

    def ordered_results;          end
    def reversed_ordered_results; end
    def result_count(type = nil); end

    # Callbacks

    # define callback handlers to do special behavior during the test run.  These
    # will be called by the test runner

    def before_load(test_files); end
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
