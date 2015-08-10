require 'assert/suite'

module Assert

  # This is the default suite used by assert.  It stores test/result data in-memory.

  class DefaultSuite < Assert::Suite

    # Test data

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

    def test_count
      self.tests.size
    end

    # Result data

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

    def result_count(type = nil)
      self.tests.inject(0){ |count, test| count += test.result_count(type) }
    end

    # Callbacks

    # no custom callbacks

  end

end
