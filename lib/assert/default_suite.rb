require 'assert/suite'

module Assert

  # TODO: make this comment/description more accurate once accumulation work done
  # This is the default suite used by assert.  It stores test/result data in-memory.

  class DefaultSuite < Assert::Suite

    # TODO: remove once ordered methods are moved to the view
    attr_reader :tests

    def initialize(config)
      super
      @tests = []
      reset_run_data
    end

    def tests_to_run?;      @tests.size > 0; end
    def tests_to_run_count; @tests.size;     end
    def clear_tests_to_run; @tests.clear;    end

    def find_test_to_run(file_line)
      @tests.find{ |t| t.file_line == file_line }
    end

    def sorted_tests_to_run(&sort_by_proc)
      @tests.sort.sort_by(&sort_by_proc)
    end

    def test_count;          @test_count;          end
    def result_count;        @result_count;        end
    def pass_result_count;   @pass_result_count;   end
    def fail_result_count;   @fail_result_count;   end
    def error_result_count;  @error_result_count;  end
    def skip_result_count;   @skip_result_count;   end
    def ignore_result_count; @ignore_result_count; end

    # TODO: move all these ordered methods to the view as it is only needed by
    # the view for presentation purposes

    def ordered_tests
      self.tests
    end

    def reversed_tests
      self.tests.reverse
    end

    def ordered_tests_by_run_time
      self.ordered_tests.sort{ |a, b| a.run_time <=> b.run_time }
    end

    def reversed_tests_by_run_time
      self.ordered_tests_by_run_time.reverse
    end

    def ordered_results
      self.ordered_tests.inject([]){ |results, test| results += test.results }
    end

    def reversed_results
      self.ordered_results.reverse
    end

    # dump failed or errored results,
    # dump skipped or ignored results if they have a message
    def ordered_results_for_dump
      self.ordered_results.select do |result|
        [:fail, :error].include?(result.to_sym) ||
        !!([:skip, :ignore].include?(result.to_sym) && result.message)
      end
    end

    def reversed_results_for_dump
      self.ordered_results_for_dump.reverse
    end

    # Callbacks

    def on_test(test)
      @tests << test
    end

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
