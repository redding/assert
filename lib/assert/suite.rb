require 'assert/test'

module Assert
  class Suite < ::Hash

    # A suite is a set of tests to run.  When a test class subclasses
    # the Context class, that test class is pushed to the suite.

    attr_accessor :start_time, :end_time, :setup_blocks, :teardown_blocks

    def run_time
      (@end_time || 0) - (@start_time || 0)
    end

    def <<(context_klass)
      # gsub off any trailing 'Test'
      self[context_klass] ||= []
    end

    def contexts
      self.keys.sort{|a,b| a.to_s <=> b.to_s}
    end

    def tests
      prep
      self.values.flatten
    end

    def ordered_tests(klass=nil)
      prep
      (klass.nil? ? self.contexts : [klass]).inject([]) do |tests, klass|
        tests += (self[klass] || [])
      end
    end

    def ordered_results(klass=nil)
      ordered_tests(klass).inject([]) do |results, test|
        results += test.results
      end
    end

    def test_count(klass=nil)
      prep
      count_tests(klass.nil? ? self.values : [self[klass]])
    end

    def result_count(type=nil)
      prep
      count_results(self.values, type)
    end

    def count(thing)
      case thing
      when :tests
        test_count
      when :results
        result_count
      when :passed, :pass
        result_count(:pass)
      when :failed, :fail
        result_count(:fail)
      when :ignored, :ignore
        result_count(:ignore)
      when :skipped, :skip
        result_count(:skip)
      when :errored, :error
        result_count(:error)
      else
        0
      end
    end

    def setup_blocks
      @setup_blocks ||= []
    end

    def teardown_blocks
      @teardown_blocks ||= []
    end

    # TODO: tests!
    def setup(&block)
      raise ArgumentError, "please provide a setup block" unless block_given?
      self.setup_blocks << block
    end

    # TODO: tests!
    def teardown(&block)
      raise ArgumentError, "please provide a teardown block" unless block_given?
      self.teardown_blocks << block
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

    def count_results(test_sets, type)
      self.values.flatten.inject(0){|count, test| count += test.result_count(type) }
    end

    def prep
      if @prepared != true
        # look for local public methods starting with 'test_'and add
        self.each do |context, tests|
          local_public_test_methods(context).each do |meth|
            tests << Test.new(meth.to_s, meth, context)
          end
          tests.uniq
        end
      end
      @prepared = true
    end

  end

end
