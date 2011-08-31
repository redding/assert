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

    # if a class subclasses Context, add it to the suite
    def self.inherited(klass)
      Assert.suite << klass
    end

    # put all logic here to keep context instances pure for running tests
    class << self

      def setup_once(&block)
        Assert.suite.setup(&block)
      end
      alias_method :before_once, :setup_once

      def teardown_once(&block)
        Assert.suite.teardown(&block)
      end
      alias_method :after_once, :teardown_once

      # Add a setup block to run before each test or run the list of teardown blocks in given scope
      def setup(scope=nil, &block)
        if block_given?
          self.setups << block
        elsif scope
          # setup parent before child
          self.superclass.setup(scope) if self.superclass.respond_to?(:setup)
          self.setups.each{|setup| scope.instance_eval(&setup)}
        end
      end
      alias_method :before, :setup

      # Add a teardown block to run after each test or run the list of teardown blocks in given scope
      def teardown(scope=nil, &block)
        if block_given?
          self.teardowns << block
        elsif scope
          # teardown child before parent
          self.teardowns.each{|teardown| scope.instance_eval(&teardown)}
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

      def subject(&block)
        if block_given?
          @subject = block
        else
          @subject || if superclass.respond_to?(:subject)
            superclass.subject
          end
        end
      end

      def test(desc_or_macro, &block)
        if desc_or_macro.kind_of?(Macro)
          instance_eval(&desc_or_macro)
        else
          method_name = "test: #{desc_or_macro}"

          # if no block given, create a test that just skips
          method_block = block_given? ? block : (Proc.new { skip })

          # instead of using the typical 'method_defined?' pattern (which) checks
          # all parent contexts, we really just need to make sure the method_name
          # is not part of self's local_pulic_test_methods for this check
          if Assert.suite.send(:local_public_test_methods, self).include?(method_name)
            from = caller.first
            puts "WARNING: should #{desc_or_macro.inspect} is redefining #{method_name}!"
            puts "  from: #{from}"
            puts "  self: #{self.inspect}"
          end

          define_method(method_name, &method_block)
        end
      end

      def test_eventually(desc, &block)
        test(desc)
      end
      alias_method :test_skip, :test_eventually

      def should(desc_or_macro, &block)
        if !desc_or_macro.kind_of?(Macro)
          desc_or_macro = "should #{desc_or_macro}"
        end
        test(desc_or_macro, &block)
      end

      def should_eventually(desc, &block)
        should(desc)
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
      if subj = self.class.subject
        instance_eval(&subj)
      end
    end

    def inspect
      "#<#{self.class}>"
    end

    protected

    # Returns a Proc that will output a custom message along with the default fail message.
    def fail_message(fail_desc=nil, &what_failed)
      fail_desc.kind_of?(::Proc) ? fail_desc : Proc.new do
        [ fail_desc, what_failed.call ].compact.join("\n")
      end
    end

    private

    def capture_result
      if block_given?
        result = yield @__running_test__.name, caller
        @__running_test__.results << result
        result
      end
    end

  end
end
