module Assert
  class Suite < ::Hash

    # A suite is a set of tests to run.  When a test class subclasses
    # the Context class, that test class is pushed to the suite.

    # TODO: test
    attr_accessor :start_time, :end_time

    def run_time
      @end_time - @start_time
    end

    def <<(context_klass)
      # gsub off any trailing 'Test'
      self[context_klass] ||= []
    end

    def contexts
      prep

      # collect the set of context instances for the suite and return
      # this is the set of things a runner needs to run
      contexts = []
      self.each do |klass, tests|
        tests.each {|test| contexts << klass.new(test)}
      end
      contexts
    end

    def count(thing)
      case thing
      when :tests
        test_count
      when :assertions
        assert_count
      when :passed, :pass
        assert_count(:pass)
      when :failed, :fail
        assert_count(:fail)
      when :skipped, :skip
        assert_count(:skip)
      when :errored, :error
        assert_count(:error)
      else
        0
      end
    end

    def test_count(klass=nil)
      prep
      count_tests(klass.nil? ? self.values : [self[klass]])
    end

    def assert_count(type=nil)
      count_asserts(self.values, type)
    end

    protected

    def local_public_test_methods(klass)
      methods = klass.public_instance_methods
      while (klass.superclass)
        methods -= (klass = klass.superclass).public_instance_methods
      end
      methods.delete_if {|method_name| method_name !~ /^test_./}
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

    def prep
      if @prepared != true
        # look for local public methods starting with 'test_'and add
        self.each do |klass, tests|
          local_public_test_methods(klass).each do |meth|
            tests << Test.new(meth.to_s, meth)
          end
          tests.uniq
        end
      end
      @prepared = true
    end

  end

  # the set of contexts to run
  @@suite = Suite.new

  class << self

    # access the suite
    def suite
      @@suite
    end

  end

end
