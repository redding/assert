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

      def setup(&block)
        raise ArgumentError, "please provide a setup block" unless block_given?
        @_assert_setups ||= []
        @_assert_setups << block
      end
      alias_method :before, :setup

      def teardown(&block)
        raise ArgumentError, "please provide a teardown block" unless block_given?
        @_assert_teardowns ||= []
        @_assert_teardowns << block
      end
      alias_method :after, :teardown

      def _assert_setups
        setups = if superclass.respond_to?(:_assert_setups)
          superclass._assert_setups
        end
        (setups || []) + (@_assert_setups || [])
      end

      def _assert_teardowns
        teardowns = if superclass.respond_to?(:_assert_teardowns)
          superclass._assert_teardowns
        end
        (@_assert_teardowns || []) + (teardowns || [])
      end

      def desc(description)
        raise ArgumentError, "no context description provided" if description.nil?
        @_assert_desc ||= [ description ]
      end

      def _assert_descs
        descs = if superclass.respond_to?(:_assert_descs)
          superclass._assert_descs
        end
        (descs || []) + (@_assert_desc || [])
      end

      def subject(&block)
        raise ArgumentError, "please provide a subject block" unless block_given?
        @_assert_subject = block
      end

      def _assert_subject
        @_assert_subject
      end

    end

    def initialize(running_test = nil)
      @__running_test__ = running_test
    end

    # raise Result::Fail if the assertion is false or nil
    def assert(assertion, fail_desc=nil, what_failed_msg=nil)
      what_failed_msg ||= "Failed assert."
      msg = fail_message(fail_desc) { what_failed_msg }
      assertion ? pass : fail(msg)
    end

    # the opposite of assert, raise Result::Fail if the assertion is not false or nil
    def assert_not(assertion, fail_desc=nil)
      assert(!assertion, fail_desc, "Failed refute.")
    end
    alias_method :refute, :assert_not

    # adds a Skip result to the end of the test's results and breaks test execution
    def skip
      raise Result::TestSkipped
    end

    # adds a Pass result to the end of the test's results
    # does not break test execution
    def pass
      capture_result do |test_name, backtrace|
        Assert::Result::Pass.new(test_name, nil, backtrace)
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

    def subject
      if subject_block = self.class._assert_subject
        instance_eval(&subject_block)
      end
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
    def fail_message(custom_msg=nil, &default_msg)
      custom_msg.kind_of?(::Proc) ? custom_msg : Proc.new do
        [ default_msg.call, custom_msg ].compact.join("\n")
      end
    end

  end
end
