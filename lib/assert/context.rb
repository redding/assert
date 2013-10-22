require 'assert/suite'
require 'assert/assertions'
require 'assert/result'
require 'assert/macros/methods'

module Assert
  class Context
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

        if Assert.suite.test_methods.include?(klass_method_name)
          puts "WARNING: redefining '#{klass_method_name}'"
          puts "  from: #{called_from}"
        else
          Assert.suite.test_methods << klass_method_name
        end

        ci = Suite::ContextInfo.new(self, nil, caller.first)
        Assert.suite.tests << Test.new(method_name.to_s, ci, method_name)
      end
    end

    # put all logic here to keep context instances pure for running tests
    class << self

      def setup_once(&block)
        Assert.suite.setup(&block)
      end
      alias_method :before_once, :setup_once
      alias_method :startup, :setup_once

      def teardown_once(&block)
        Assert.suite.teardown(&block)
      end
      alias_method :after_once, :teardown_once
      alias_method :shutdown, :teardown_once

      # Add a setup block to run before each test or run the list of teardown blocks in given scope
      def setup(scope_or_method_name = nil, &block)
        is_method = scope_or_method_name.kind_of?(String) || scope_or_method_name.kind_of?(Symbol)
        if block_given? || is_method
          # arg is a block or method that needs to be stored as a setup
          self.setups << (block || scope_or_method_name)
        elsif !is_method
          # arg is an instance of this class (the scope for a test),
          # run the setups for this context in the scope
          scope = scope_or_method_name
          # setup parent...
          self.superclass.setup(scope) if self.superclass.respond_to?(:setup)
          # ... before child
          self.setups.each do |setup|
            setup.kind_of?(::Proc) ? scope.instance_eval(&setup) : scope.send(setup)
          end
        end
      end
      alias_method :before, :setup

      # Add a teardown block to run after each test or run the list of teardown blocks in given scope
      def teardown(scope_or_method_name = nil, &block)
        is_method = scope_or_method_name.kind_of?(String) || scope_or_method_name.kind_of?(Symbol)
        if block_given? || is_method
          # arg is a block or method that needs to be stored as a teardown
          self.teardowns << (block || scope_or_method_name)
        elsif !is_method
          # arg is an instance of this class (the scope for a test),
          # run the setups for this context in the scope
          scope = scope_or_method_name
          # teardown child...
          self.teardowns.each do |teardown|
            teardown.kind_of?(::Proc) ? scope.instance_eval(&teardown) : scope.send(teardown)
          end
          # ... before parent
          self.superclass.teardown(scope) if self.superclass.respond_to?(:teardown)
        end
      end
      alias_method :after, :teardown

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
      alias_method :describe, :description

      def subject(&block)
        if block_given?
          @subject = block
        else
          @subject || if superclass.respond_to?(:subject)
            superclass.subject
          end
        end
      end

      def test(desc_or_macro, called_from=nil, first_caller=nil, &block)
        if desc_or_macro.kind_of?(Macro)
          instance_eval(&desc_or_macro)
        elsif block_given?
          ci = Suite::ContextInfo.new(self, called_from, first_caller || caller.first)
          test_name = desc_or_macro

          # create a test from the given code block
          Assert.suite.tests << Test.new(test_name, ci, &block)
        else
          test_eventually(desc_or_macro, called_from, first_caller || caller.first, &block)
        end
      end

      def test_eventually(desc_or_macro, called_from=nil, first_caller=nil, &block)
        ci = Suite::ContextInfo.new(self, called_from, first_caller || caller.first)
        test_name = desc_or_macro.kind_of?(Macro) ? desc_or_macro.name : desc_or_macro
        skip_block = block.nil? ? Proc.new { skip 'TODO' } : Proc.new { skip }

        # create a test from a proc that just skips
        Assert.suite.tests << Test.new(test_name, ci, &skip_block)
      end
      alias_method :test_skip, :test_eventually

      def should(desc_or_macro, called_from=nil, first_caller=nil, &block)
        if !desc_or_macro.kind_of?(Macro)
          desc_or_macro = "should #{desc_or_macro}"
        end
        test(desc_or_macro, called_from, first_caller || caller.first, &block)
      end

      def should_eventually(desc_or_macro, called_from=nil, first_caller=nil, &block)
        if !desc_or_macro.kind_of?(Macro)
          desc_or_macro = "should #{desc_or_macro}"
        end
        test_eventually(desc_or_macro, called_from, first_caller || caller.first, &block)
      end
      alias_method :should_skip, :should_eventually

      protected

      def descriptions
        @descriptions ||= []
      end

      def setups
        @setups ||= []
      end

      def teardowns
        @teardowns ||= []
      end

    end

    def initialize(running_test = nil)
      @__running_test__ = running_test
    end

    # check if the assertion is a truthy value, if so create a new pass result, otherwise
    # create a new fail result with the desc and what failed msg.
    # all other assertion helpers use this one in the end
    def assert(assertion, fail_desc = nil)
      if assertion
        pass
      else
        what_failed_msg = block_given? ? yield : "Failed assert: assertion was <#{assertion.inspect}>."
        fail(fail_message(fail_desc, what_failed_msg))
      end
    end

    # the opposite of assert, check if the assertion is a false value, if so create a new pass
    # result, otherwise create a new fail result with the desc and it's what failed msg
    def assert_not(assertion, fail_desc = nil)
      assert(!assertion, fail_desc){ "Failed assert_not: assertion was <#{assertion.inspect}>." }
    end
    alias_method :refute, :assert_not

    # adds a Pass result to the end of the test's results
    # does not break test execution
    def pass(pass_msg=nil)
      capture_result do |test, backtrace|
        Assert::Result::Pass.new(test, pass_msg, backtrace)
      end
    end

    # adds an Ignore result to the end of the test's results
    # does not break test execution
    def ignore(ignore_msg=nil)
      capture_result do |test, backtrace|
        Assert::Result::Ignore.new(test, ignore_msg, backtrace)
      end
    end

    # adds a Fail result to the end of the test's results
    # break test execution if Assert.config.halt_on_fail
    def fail(message = nil)
      if Assert.config.halt_on_fail
        raise Result::TestFailure, message || ''
      else
        capture_result do |test, backtrace|
          Assert::Result::Fail.new(test, message || '', backtrace)
        end
      end
    end
    alias_method :flunk, :fail

    # adds a Skip result to the end of the test's results and breaks test execution
    def skip(skip_msg=nil)
      raise(Result::TestSkipped, skip_msg || '')
    end

    # alter the backtraces of fail results generated in the given block
    def with_backtrace(bt, &block)
      bt ||= []
      current_results.count.tap do |count|
        begin
          instance_eval(&block)
        rescue Result::TestSkipped, Result::TestFailure => e
          e.set_backtrace(bt); raise(e)
        ensure
          current_results[count..-1].each{ |r| r.set_backtrace(bt) }
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

    def capture_result
      if block_given?
        result = yield @__running_test__, caller
        @__running_test__.results << result
        result
      end
    end

    def current_results
      @__running_test__.results
    end

  end
end
