require 'assert/test'

module Assert
  class Suite < ::Hash

    # A suite is a set of tests to run.  When a test class subclasses
    # the Context class, that test class is pushed to the suite.

    attr_accessor :start_time, :end_time

    def run_time
      (@end_time || 0) - (@start_time || 0)
    end

    def runner_seed
      @run_seed ||= (ENV["runner_seed"] || begin
        srand
        srand % 0xFFFF
      end).to_i
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

    def setup(&block)
      if block_given?
        self.setups << block
      else
        self.setups.each{|setup| setup.call}
      end
    end
    alias_method :startup, :setup

    def teardown(&block)
      if block_given?
        self.teardowns << block
      else
        self.teardowns.reverse.each{|teardown| teardown.call}
      end
    end
    alias_method :shutdown, :teardown

    protected

    def setups
      @setups ||= []
    end

    def teardowns
      @teardowns ||= []
    end

    def local_public_test_methods(klass)
      # start with all public meths, store off the local ones
      methods = klass.public_instance_methods
      local_methods = klass.public_instance_methods(false)

      # remove any from the superclass
      while (klass.superclass)
        methods -= (klass = klass.superclass).public_instance_methods
      end

      # add back in the local ones (to work around super having the same methods)
      methods += local_methods

      # uniq and remove any that don't start with 'test'
      methods.uniq.delete_if {|method_name| method_name !~ /^test./ }
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
        self.each do |context_class, tests|
          local_public_test_methods(context_class).each do |meth|
            tests << Test.new(meth.to_s, context_class, meth)
          end
          tests.uniq
        end
      end
      @prepared = true
    end

  end

end
