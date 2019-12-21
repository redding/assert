require "assert/suite"

module Assert
  # This is the default suite used by assert. In addition to the base suite
  # behavior, it accumulates test/result counts in memory.  This data is used
  # by the runner/view for handling and presentation purposes.
  class DefaultSuite < Assert::Suite
    def initialize(config)
      super
      reset_run_data
    end

    def test_count;          @test_count;          end
    def result_count;        @result_count;        end
    def pass_result_count;   @pass_result_count;   end
    def fail_result_count;   @fail_result_count;   end
    def error_result_count;  @error_result_count;  end
    def skip_result_count;   @skip_result_count;   end
    def ignore_result_count; @ignore_result_count; end

    # Callbacks

    def on_start
      reset_run_data
    end

    def before_test(test)
      @test_count += 1
    end

    def on_result(result)
      @result_count += 1
      self.send("increment_#{result.type}_result_count")
    end

    private

    def increment_pass_result_count;   @pass_result_count   += 1; end
    def increment_fail_result_count;   @fail_result_count   += 1; end
    def increment_error_result_count;  @error_result_count  += 1; end
    def increment_skip_result_count;   @skip_result_count   += 1; end
    def increment_ignore_result_count; @ignore_result_count += 1; end

    def reset_run_data
      @test_count          = 0
      @result_count        = 0
      @pass_result_count   = 0
      @fail_result_count   = 0
      @error_result_count  = 0
      @skip_result_count   = 0
      @ignore_result_count = 0
    end
  end
end
