require 'assert/suite'
require 'assert/result'

module Assert
  class Context

    # a Context is a scope for tests to run in.  Contexts have setup and
    # teardown blocks, subjects, and descriptions.  Tests are run in the
    # scope of a Context instance.  Therefore, a Context should have
    # no base logic/methods/instance_vars.  The instance should remain
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
      @__test = test
      begin
        # TODO: setups
        if test.code.kind_of?(::Proc)
          instance_eval(&test.code)
        elsif self.respond_to?(test.code.to_s)
          self.send(test.code.to_s)
        end
        # TODO: teardowns
      rescue Result::Base => err
        @__test.results << err
      rescue Exception => err
        @__test.results << Result::Error.new(err)
      end
    end

    # the basic building block to run any type of assertion
    # raise Result::Fail if the condition is not true
    def assert(condition, fail_message=nil)
      begin
        if condition == true
          raise Result::Pass
        else
          raise Result::Fail, fail_message || "<#{condition.inspect}> is not true"
        end
      rescue Result::Pass => err
        @__test.results << err
        err
      rescue Result::Fail => err
        @__test.results << err
        err
      end
    end

    # call this method to break test execution at any point in the test
    # adds a Skip result to the end of the test's results
    def skip
      raise Result::Skip
    end

    # call this method to break test execution at any point in the test
    # adds a Fail result to the end of the test's results
    def fail(fail_message=nil)
      raise Result::Fail, fail_message
    end
    alias_method :flunk, :fail

  end
end
