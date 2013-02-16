require 'assert/test'

module Assert
  class Suite

    class ContextInfo

      attr_reader :called_from, :first_caller, :klass, :file

      def initialize(klass, called_from=nil, first_caller=nil)
        @first_caller = first_caller
        @called_from = called_from
        @klass = klass
        @file = if (@called_from || @first_caller)
          (@called_from || @first_caller).gsub(/\:[0-9]+.*$/, '')
        end
      end

    end

    TEST_METHOD_REGEX = /^test./

    # A suite is a set of tests to run.  When a test class subclasses
    # the Context class, that test class is pushed to the suite.

    attr_accessor :tests, :test_methods, :start_time, :end_time

    def initialize
      @tests = []
      @test_methods = []
      @start_time = 0
      @end_time = 0
    end

    def run_time
      @end_time - @start_time
    end

    alias_method :ordered_tests, :tests

    def results
      tests.inject([]) {|results, test| results += test.results}
    end
    alias_method :ordered_results, :results

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

    def test_count
      self.tests.size
    end

    def result_count(type=nil)
      if type
        self.tests.inject(0) do |count, test|
          count += test.result_count(type)
        end
      else
        self.results.size
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
      methods.uniq.delete_if {|method_name| method_name !~ TEST_METHOD_REGEX }
    end

  end

end
