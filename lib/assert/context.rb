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

    end

    def initialize(test=nil)
      return if test.nil? || !test.kind_of?(Test)
      @_test = test
    end

    def run
      begin
        # TODO: setups
        if @_test.code.kind_of?(::Proc)
          instance_eval(&@_test.code)
        elsif self.respond_to?(@_test.code.to_s)
          self.send(@_test.code.to_s)
        end
        # TODO: teardowns
      rescue Result::Base => err
        @_test.results << err
      rescue Exception => err
        @_test.results << Result::Error.new(err)
      end
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

    # capture a pass or fail result from a given block and return it
    # handles adding any fail_msg to fail results.
    def assertion_result
      begin
        yield if block_given?
      rescue Result::Pass => err
        @_test.results << err
        err
      rescue Result::Fail => err
        @_test.results << err
        err
      else
        raise RuntimeError, "no pass or fail result captured"
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
