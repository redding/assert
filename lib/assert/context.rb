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

    end

    def initialize(running_test = nil)
      @__running_test__ = running_test
    end

    # raise Result::Fail if the assertion is false or nil
    def assert(assertion, fail_msg=nil)
      msg = fail_message(fail_msg) { "Failed assert.  No message given." }
      assertion_result { assertion ? pass : fail(msg) }
    end

    # the opposite of assert, raise Result::Fail if the assertion is not false or nil
    def refute(assertion, fail_msg=nil)
      msg = fail_message(fail_msg) { "Failed refute.  No message given." }
      assertion_result { assertion ? fail(msg) : pass }
    end

    # call this method to break test execution at any point in the test
    # adds a Skip result to the end of the test's results
    def skip
      raise Result::Skip
    end

    # call this method to break test execution at any point in the test
    # adds a Pass result to the end of the test's results
    def pass
      raise Result::Pass
    end

    # call this method to break test execution at any point in the test
    # adds a Fail result to the end of the test's results
    def fail(fail_msg=nil)
      raise Result::Fail, (fail_message(fail_msg) { }).call
    end
    alias_method :flunk, :fail

    protected

    # ask the running test to handle the result of the assertion and decide how to store
    # that result
    def assertion_result(&block)
      @__running_test__.assertion_result(&block)
    end

    # Returns a Proc that will output a custom message along with the default fail message.
    def fail_message(custom_msg=nil, &default_msg)
      custom_msg.kind_of?(::Proc) ? custom_msg : Proc.new do
        [ default_msg.call, custom_msg ].compact.join("\n")
      end
    end

  end
end
