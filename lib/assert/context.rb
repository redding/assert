require 'assert/assertions'
require 'assert/context/setup_dsl'
require 'assert/context/subject_dsl'
require 'assert/context/suite_dsl'
require 'assert/context/test_dsl'
require 'assert/context_info'
require 'assert/macros/methods'
require 'assert/result'
require 'assert/suite'
require 'assert/utils'

module Assert

  class Context
    # put all logic in DSL methods to keep context instances pure for running tests
    extend SetupDSL
    extend SubjectDSL
    extend SuiteDSL
    extend TestDSL
    include Assert::Assertions
    include Assert::Macros::Methods

    # a Context is a scope for tests to run in.  Contexts have setup and
    # teardown blocks, subjects, and descriptions.  Tests are run in the
    # scope of a Context instance.  Therefore, a Context should have
    # minimal base logic/methods/instance_vars.  The instance should remain
    # pure to not pollute test scopes.

    # if a test method is added to a context manually (not using a context helper):
    # capture any context info, build a test obj, and add it to the suite
    def self.method_added(method_name)
      if method_name.to_s =~ Suite::TEST_METHOD_REGEX
        klass_method_name = "#{self}##{method_name}"

        if self.suite.test_methods.include?(klass_method_name)
          puts "WARNING: redefining '#{klass_method_name}'"
          puts "  from: #{caller.first}"
        else
          self.suite.test_methods << klass_method_name
        end

        self.suite.on_test(Test.for_method(
          method_name.to_s,
          ContextInfo.new(self, nil, caller.first),
          self.suite.config
        ))
      end
    end

    def initialize(running_test, config, result_callback)
      @__running_test__    = running_test
      @__assert_config__   = config
      @__result_callback__ = result_callback
    end

    # check if the assertion is a truthy value, if so create a new pass result, otherwise
    # create a new fail result with the desc and what failed msg.
    # all other assertion helpers use this one in the end
    def assert(assertion, desc = nil)
      if assertion
        pass
      else
        what = if block_given?
          yield
        else
          "Failed assert: assertion was `#{Assert::U.show(assertion, __assert_config__)}`."
        end
        fail(fail_message(desc, what))
      end
    end

    # the opposite of assert, check if the assertion is a false value, if so create a new pass
    # result, otherwise create a new fail result with the desc and it's what failed msg
    def assert_not(assertion, fail_desc = nil)
      assert(!assertion, fail_desc) do
        "Failed assert_not: assertion was `#{Assert::U.show(assertion, __assert_config__)}`."
      end
    end
    alias_method :refute, :assert_not

    # adds a Pass result to the end of the test's results
    # does not break test execution
    def pass(pass_msg = nil)
      capture_result do |test, backtrace|
        Assert::Result::Pass.for_test(test, pass_msg, backtrace)
      end
    end

    # adds an Ignore result to the end of the test's results
    # does not break test execution
    def ignore(ignore_msg = nil)
      capture_result do |test, backtrace|
        Assert::Result::Ignore.for_test(test, ignore_msg, backtrace)
      end
    end

    # adds a Fail result to the end of the test's results
    # break test execution if assert is configured to halt on failures
    def fail(message = nil)
      if halt_on_fail?
        raise Result::TestFailure, message || ''
      else
        capture_result do |test, backtrace|
          Assert::Result::Fail.for_test(test, message || '', backtrace)
        end
      end
    end
    alias_method :flunk, :fail

    # adds a Skip result to the end of the test's results and breaks test execution
    def skip(skip_msg = nil, called_from = nil)
      err = Result::TestSkipped.new(skip_msg || '')
      err.set_backtrace([called_from]) if called_from
      raise(err)
    end

    # alter the backtraces of fail results generated in the given block
    def with_backtrace(bt, &block)
      bt ||= []
      current_results.size.tap do |size|
        begin
          instance_eval(&block)
        rescue Result::TestSkipped, Result::TestFailure => e
          e.set_backtrace(bt); raise(e)
        ensure
          current_results[size..-1].each{ |r| r.set_backtrace(bt) }
        end
      end
    end

    def subject
      if subj = self.class.subject
        instance_eval(&subj)
      end
    end

    def inspect
      "#<#{self.class}>"
    end

    protected

    # Returns a Proc that will output a custom message along with the default fail message.
    def fail_message(fail_desc = nil, what_failed_msg = nil)
      [ fail_desc, what_failed_msg ].compact.join("\n")
    end

    private

    def halt_on_fail?
      __assert_config__.halt_on_fail
    end

    def capture_result
      if block_given?
        result = yield __running_test__, caller
        __running_test__.capture_result(result, @__result_callback__)
        result
      end
    end

    def current_results
      __running_test__.results
    end

    def __running_test__
      @__running_test__
    end

    def __assert_config__
      @__assert_config__
    end

  end
end
