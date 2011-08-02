module Assert
  class Suite < ::Hash

    # A suite is a set of tests to run.  When a test class subclasses
    # the Context class, that test class is pushed to the suite.

    def <<(context_klass)
      # gsub off any trailing 'Test'
      self[context_klass] ||= []
    end

    def run
      self.each do |context_klass, tests|
        # TODO: look for local public methods stating with 'test_'and add
        # TODO: provide options for test order
        tests.each do |test|
          context_klass.new(test)
        end
      end
    end

    def test_count(klass=nil)
      count_tests(klass.nil? ? self.values : self[klass])
    end

    def assert_count(type=nil)
      count_asserts(self.values, type)
    end

    private

    def count_tests(test_sets)
      test_sets.inject(0) {|count, tests| count += tests.size}
    end

    def count_asserts(test_sets, type)
      test_sets.inject(0) do |count, tests|
        count += tests.inject(0) {|count, test| count += test.assert_count(type)}
      end
    end

  end
end
