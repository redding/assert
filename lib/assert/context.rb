require 'assert/suite'
require 'assert/assertions'
require 'assert/result'

module Assert
  class Context
    include Assert::Assertions

    # a Context is a scope for tests to run in.  Contexts have setup and
    # teardown blocks, subjects, and descriptions.  Tests are run in the
    # scope of a Context instance.  Therefore, a Context should have
    # minimal base logic/methods/instance_vars.  The instance should remain
    # pure to not pollute test scopes.

    # if a class subclasses Context, add it to the suite
    def self.inherited(klass)
      Assert.suite << klass
    end

    # put all logic here to keep context instances pure for running tests
    class << self
      attr_accessor :subject_block

      def setup_once(&block)
        Assert.suite.setup(&block)
      end
      alias_method :before_once, :setup_once

      def teardown_once(&block)
        Assert.suite.teardown(&block)
      end
      alias_method :after_once, :teardown_once

      def setup(&block)
        raise ArgumentError, "please provide a setup block" unless block_given?
        self.setup_blocks << block
      end
      alias_method :before, :setup

      def teardown(&block)
        raise ArgumentError, "please provide a teardown block" unless block_given?
        self.teardown_blocks << block
      end
      alias_method :after, :teardown

      def setup_blocks
        @setup_blocks ||= []
      end

      def teardown_blocks
        @teardown_blocks ||= []
      end

      def all_setup_blocks
        inherited_blocks = if superclass.respond_to?(:all_setup_blocks)
          superclass.all_setup_blocks
        end
        (inherited_blocks || []) + self.setup_blocks
      end

      def all_teardown_blocks
        inherited_blocks = if superclass.respond_to?(:all_teardown_blocks)
          superclass.all_teardown_blocks
        end
        (inherited_blocks || []) + self.teardown_blocks
      end

      def subject(&block)
        raise ArgumentError, "please provide a subject block" unless block_given?
        self.subject_block = block
      end

      def subject_block
        @subject_block ||= if superclass.respond_to?(:subject_block)
          superclass.subject_block
        end
      end

      def should(desc, &block)
        raise ArgumentError, "please provide a test block" unless block_given?
        method_name = "test: should #{desc}"
        if method_defined?(method_name)
          from = caller.first
          puts "WARNING: should #{desc.inspect} is redefining #{method_name}!"
          puts "  from: #{from}"
        end
        define_method(method_name, &block)
      end

      def should_eventually(desc, &block)
        should(desc){ skip }
      end

      # Add a piece of description text or return the full description for the context
      def description(text=nil)
        if text
          self.descriptions << text.to_s
        else
          parent = self.superclass.desc if self.superclass.respond_to?(:desc)
          own = self.descriptions
          [parent, *own].compact.reject do |p|
            p.to_s.empty?
          end.join(" ")
        end
      end
      alias_method :desc, :description

      protected

      def descriptions
        @descriptions ||= []
      end

    end

    def initialize(running_test = nil)
      @__running_test__ = running_test
    end

    # check if the assertion is a truthy value, if so create a new pass result, otherwise
    # create a new fail result with the desc and what failed msg.
    # all other assertion helpers use this one in the end
    def assert(assertion, fail_desc=nil, what_failed_msg=nil)
      what_failed_msg ||= "Failed assert: assertion was <#{assertion.inspect}>."
      msg = fail_message(fail_desc) { what_failed_msg }
      assertion ? pass : fail(msg)
    end

    # the opposite of assert, check if the assertion is a false value, if so create a new pass
    # result, otherwise create a new fail result with the desc and it's what failed msg
    def assert_not(assertion, fail_desc=nil)
      what_failed_msg = "Failed assert_not: assertion was <#{assertion.inspect}>."
      assert(!assertion, fail_desc, what_failed_msg)
    end
    alias_method :refute, :assert_not

    # adds a Skip result to the end of the test's results and breaks test execution
    def skip(skip_msg=nil)
      raise(Result::TestSkipped, skip_msg || "")
    end

    # adds a Pass result to the end of the test's results
    # does not break test execution
    def pass(pass_msg=nil)
      capture_result do |test_name, backtrace|
        Assert::Result::Pass.new(test_name, pass_msg, backtrace)
      end
    end

    # adds a Fail result to the end of the test's results
    # does not break test execution
    def fail(fail_msg=nil)
      capture_result do |test_name, backtrace|
        message = (fail_message(fail_msg) { }).call
        Assert::Result::Fail.new(test_name, message, backtrace)
      end
    end
    alias_method :flunk, :fail

    # adds an Ignore result to the end of the test's results
    # does not break test execution
    def ignore(ignore_msg=nil)
      capture_result do |test_name, backtrace|
        Assert::Result::Ignore.new(test_name, ignore_msg, backtrace)
      end
    end

    def subject
      if subject_block = self.class.subject_block
        instance_eval(&subject_block)
      end
    end

    def inspect
      "#<#{self.class}>"
    end

    protected

    def capture_result
      if block_given?
        result = yield @__running_test__.name, caller
        @__running_test__.results << result
        result
      end
    end

    # Returns a Proc that will output a custom message along with the default fail message.
    def fail_message(fail_desc=nil, &what_failed)
      fail_desc.kind_of?(::Proc) ? fail_desc : Proc.new do
        [ what_failed.call, fail_desc ].compact.join("\n")
      end
    end

  end
end
