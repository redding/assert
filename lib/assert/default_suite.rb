require 'assert/suite'

module Assert

  # This is the default suite used by assert.  It stores test/result data in-memory.

  class DefaultSuite < Assert::Suite

    # Test Handling

    def ordered_tests
      self.tests
    end

    def ordered_tests_by_run_time
      self.ordered_tests.sort{ |a, b| a.run_time <=> b.run_time }
    end

    def test_count
      self.tests.count
    end

    # Result Handling

    def ordered_results
      self.ordered_tests.inject([]){ |results, test| results += test.results }
    end

    def result_count(type = nil)
      self.tests.inject(0){ |count, test| count += test.result_count(type) }
    end

  end

end
