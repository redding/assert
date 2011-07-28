module Assert
  class Suite < ::Hash

    # A suite is the set contexts to run.  When a test class subclasses
    # the Context class, that klass is pushed to the suite.

    def <<(context_klass)
      self[context_klass] ||= []
    end

    def run
      self.each {|context| context.run}
    end

    def count(type)
      case type
      when :tests
        @tests_count ||= self.values.inject(0) do |test_count, context_tests|
          test_count += context_tests.size
        end
      when :assertions
        @assertions_count ||= self.values.inject(0) do |test_count, context_tests|
          test_count += context_tests.inject(0) do |assertion_count, test|
            assertion_count += test.assertion_count
          end
        end
      when :passed
        0
      when :failed
        0
      when :skipped
        0
      when :errored
        0
      end
    end

  end
end
