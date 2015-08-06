require 'assert/test'

module Assert
  class Suite

    TEST_METHOD_REGEX = /^test./

    # A suite is a set of tests to run.  When a test class subclasses
    # the Context class, that test class is pushed to the suite.

    attr_accessor :config, :tests, :test_methods, :start_time, :end_time

    def initialize(config)
      @config = config
      @tests = []
      @test_methods = []
      @start_time = Time.now
      @end_time = @start_time
    end

    def run_time
      @end_time - @start_time
    end

    def test_rate
      get_rate(self.tests.size, self.run_time)
    end

    def result_rate
      get_rate(self.results.size, self.run_time)
    end

    alias_method :ordered_tests, :tests

    def ordered_tests_by_run_time
      self.ordered_tests.sort{ |a, b| a.run_time <=> b.run_time }
    end

    def results
      tests.inject([]){ |results, test| results += test.results }
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

    def result_count(type = nil)
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
        self.setups.each{ |setup| setup.call }
      end
    end
    alias_method :startup, :setup

    def teardown(&block)
      if block_given?
        self.teardowns << block
      else
        self.teardowns.reverse.each{ |teardown| teardown.call }
      end
    end
    alias_method :shutdown, :teardown

    def inspect
      "#<#{self.class}:#{'0x0%x' % (object_id << 1)}"\
      " test_count=#{self.test_count.inspect}"\
      " result_count=#{self.result_count.inspect}>"
    end

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

    private

    def get_rate(count, time)
      time == 0 ? 0.0 : (count.to_f / time.to_f)
    end

    class ContextInfo

      attr_reader :called_from, :klass, :file

      def initialize(klass, called_from = nil, first_caller = nil)
        @called_from = called_from || first_caller
        @klass = klass
        @file = @called_from.gsub(/\:[0-9]+.*$/, '') if @called_from
      end

      def test_name(name)
        [klass.description.to_s, name.to_s].compact.reject(&:empty?).join(' ')
      end

    end

  end

end
