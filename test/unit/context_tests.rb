require "assert"
require "assert/context"

require "assert/config"
require "assert/result"
require "assert/utils"

class Assert::Context
  class UnitTests < Assert::Context
    desc "Assert::Context"
    subject { context1 }

    setup do
      @callback_result = nil
    end

    let(:test1)            { Factory.test }
    let(:context_class1)   { test1.context_class }
    let(:test_results1)    { [] }
    let(:result_callback1) {
      proc { |result| @callback_result = result; test_results1 << result }
    }
    let(:context1) { context_class1.new(test1, test1.config, result_callback1) }
    let(:halt_config1) { Assert::Config.new(:halt_on_fail => true) }
    let(:msg1) { Factory.string }

    # DSL methods
    should have_cmeths :description, :desc, :describe, :subject, :suite
    should have_cmeths :setup_once, :before_once, :startup
    should have_cmeths :teardown_once, :after_once, :shutdown
    should have_cmeths :setup, :before, :setups, :run_setups
    should have_cmeths :teardown, :after, :teardowns, :run_teardowns
    should have_cmeths :around, :arounds, :run_arounds
    should have_cmeths :test, :test_eventually, :test_skip
    should have_cmeths :should, :should_eventually, :should_skip

    should have_imeths :assert, :assert_not, :refute
    should have_imeths :pass, :ignore, :fail, :flunk, :skip
    should have_imeths :pending, :with_backtrace, :subject

    should "collect context info" do
      test = @__assert_running_test__
      assert_match(/test\/unit\/context_tests.rb$/, test.context_info.file)
      assert_equal self.class, test.context_info.klass
    end
    private

    ASSERT_TEST_PATH_REGEX = /\A#{File.join(ROOT_PATH, "test", "")}/

    def assert_with_bt_set(exp_with_bt, result)
      with_backtrace(caller) do
        assert_true result.with_bt_set?

        exp = Assert::Result::Backtrace.to_s(exp_with_bt+[(result.backtrace.filtered.first)])
        assert_equal exp,               result.trace
        assert_equal exp_with_bt.first, result.src_line
      end
    end

    def assert_not_with_bt_set(result)
      with_backtrace(caller) do
        assert_false result.with_bt_set?

        assert_equal result.src_line,                      result.trace
        assert_equal result.backtrace.filtered.first.to_s, result.src_line
      end
    end
  end

  class SkipTests < UnitTests
    desc "skip method"
    subject { @result }

    setup do
      begin; context1.skip(msg1); rescue StandardError => @exception; end
      @result = Factory.skip_result(@exception)
    end

    should "raise a test skipped exception and set its message" do
      assert_kind_of Assert::Result::TestSkipped, @exception
      assert_equal msg1, @exception.message
      assert_equal msg1, subject.message
    end

    should "not call the result callback" do
      assert_nil @callback_result
    end

    should "use any given called from arg as the exception backtrace" do
      assert_not_equal 1, @exception.backtrace.size

      called_from = Factory.string
      begin; context1.skip(msg1, called_from); rescue StandardError => exception; end
      assert_equal 1,           exception.backtrace.size
      assert_equal called_from, exception.backtrace.first
    end
  end

  class IgnoreTests < UnitTests
    desc "ignore method"
    subject { @result }

    setup do
      @result = context1.ignore(msg1)
    end

    should "create an ignore result and set its message" do
      assert_kind_of Assert::Result::Ignore, subject
      assert_equal msg1, subject.message
    end

    should "call the result callback" do
      assert_equal @result, @callback_result
    end
  end

  class PassTests < UnitTests
    desc "pass method"
    subject { @result }

    setup do
      @result = context1.pass(msg1)
    end

    should "create a pass result and set its message" do
      assert_kind_of Assert::Result::Pass, subject
      assert_equal msg1, subject.message
    end

    should "call the result callback" do
      assert_equal @result, @callback_result
    end
  end

  class FlunkTests < UnitTests
    desc "flunk method"
    subject { @result }

    setup do
      @result = context1.flunk(msg1)
    end

    should "create a fail result and set its message" do
      assert_kind_of Assert::Result::Fail, subject
      assert_equal msg1, subject.message
    end

    should "call the result callback" do
      assert_equal @result, @callback_result
    end
  end

  class FailTests < UnitTests
    desc "fail method"
    subject { @result }

    setup do
      @result = context1.fail
    end

    should "create a fail result and set its backtrace" do
      assert_kind_of Assert::Result::Fail, subject
      assert_equal subject.backtrace.filtered.first.to_s, subject.trace
      assert_kind_of Array, subject.backtrace
    end

    should "set any given result message" do
      result = context1.fail(msg1)
      assert_equal msg1, result.message
    end

    should "call the result callback" do
      assert_equal @result, @callback_result
    end
  end

  class HaltOnFailTests < UnitTests
    desc "failing when halting on fails"
    subject { @result }

    let(:context1) { context_class1.new(test1, halt_config1, result_callback1) }

    should "raise an exception with the failure's message" do
      begin; context1.fail(msg1); rescue StandardError => err; end
      assert_kind_of Assert::Result::TestFailure, err
      assert_equal msg1, err.message

      result = Assert::Result::Fail.for_test(Factory.test("something"), err)
      assert_equal msg1, result.message
    end

    should "not call the result callback" do
      assert_nil @callback_result
    end
  end

  class AssertTests < UnitTests
    desc "assert method"

    let(:what_failed) { Factory.string }

    should "return a pass result given a `true` assertion" do
      result = subject.assert(true, msg1){ what_failed }
      assert_kind_of Assert::Result::Pass, result
      assert_equal "", result.message
    end

    should "return a fail result given a `false` assertion" do
      result = subject.assert(false, msg1){ what_failed }
      assert_kind_of Assert::Result::Fail, result
    end

    should "pp the assertion value in the fail message by default" do
      exp_def_what = "Failed assert: assertion was `#{Assert::U.show(false, test1.config)}`."
      result = subject.assert(false, msg1)

      assert_equal [msg1, exp_def_what].join("\n"), result.message
    end

    should "use a custom fail message if one is given" do
      result = subject.assert(false, msg1){ what_failed }
      assert_equal [msg1, what_failed].join("\n"), result.message
    end

    should "return a pass result given a \"truthy\" assertion" do
      assert_kind_of Assert::Result::Pass, subject.assert(34)
    end

    should "return a fail result gievn a `nil` assertion" do
      assert_kind_of Assert::Result::Fail, subject.assert(nil)
    end
  end

  class AssertNotTests < UnitTests
    desc "assert_not method"

    should "return a pass result given a `false` assertion" do
      result = subject.assert_not(false, msg1)
      assert_kind_of Assert::Result::Pass, result
      assert_equal "", result.message
    end

    should "return a fail result given a `true` assertion" do
      result = subject.assert_not(true, msg1)
      assert_kind_of Assert::Result::Fail, result
    end

    should "pp the assertion value in the fail message by default" do
      exp_def_what = "Failed assert_not: assertion was `#{Assert::U.show(true, test1.config)}`."
      result = subject.assert_not(true, msg1)

      assert_equal [msg1, exp_def_what].join("\n"), result.message
    end

    should "return a fail result given a \"truthy\" assertion" do
      assert_kind_of Assert::Result::Fail, subject.assert_not(34)
    end

    should "return a pass result given a `nil` assertion" do
      assert_kind_of Assert::Result::Pass, subject.assert_not(nil)
    end
  end

  class SubjectTests < UnitTests
    desc "subject method"
    subject { @subject }

    setup do
      expected = expected1
      context_class1.subject { @something = expected }
      @subject = context1.subject
    end

    let(:context_class1) { Factory.modes_off_context_class }
    let(:context1) { context_class1.new(test1, test1.config, proc{ |result| }) }
    let(:expected1) { Factory.string }

    should "instance evaluate the block set with the class setup method" do
      assert_equal expected1, subject
    end
  end

  class PendingTests < UnitTests
    desc "`pending` method"

    let(:block2) { proc { fail; pass; } }
    let(:block1) { block = block2; proc { pending(&block) } } # test nesting

    should "make fails skips and make passes fails" do
      context1.fail "not affected"
      context1.pass
      context1.pending(&block1)

      assert_equal 4, test_results1.size
      norm_fail, norm_pass, pending_fail, pending_pass = test_results1

      assert_kind_of Assert::Result::Fail, norm_fail
      assert_kind_of Assert::Result::Pass, norm_pass

      assert_kind_of Assert::Result::Skip, pending_fail
      assert_includes "Pending fail", pending_fail.message

      assert_kind_of Assert::Result::Fail, pending_pass
      assert_includes "Pending pass", pending_pass.message
    end
  end

  class PendingWithHaltOnFailTests < PendingTests
    desc "when halting on fails"
    subject { @result }

    let(:context1) { context_class1.new(test1, halt_config1, result_callback1) }

    should "make fails skips and stop the test" do
      begin; context1.pending(&block1); rescue StandardError => err; end
      assert_kind_of Assert::Result::TestSkipped, err
      assert_includes "Pending fail", err.message

      assert_equal 0, test_results1.size # it halted before the pending pass
    end
  end

  class WithBacktraceTests < UnitTests
    desc "`with_backtrace` method"

    let(:from_bt1)    { ["called_from_here", Factory.string] }
    let(:from_block1) { proc { ignore; fail; pass; skip "todo"; } }

    should "alter non-error block results' bt with given bt's first line" do
      context1.fail "not affected"
      begin
        context1.with_backtrace(from_bt1, &from_block1)
      rescue Assert::Result::TestSkipped => e
        test_results1 << Assert::Result::Skip.for_test(test1, e)
      end

      assert_equal 5, test_results1.size
      norm_fail, with_ignore, with_fail, with_pass, _with_skip = test_results1

      assert_not_with_bt_set norm_fail

      exp = [from_bt1.first]
      assert_with_bt_set exp, with_ignore
      assert_with_bt_set exp, with_fail
      assert_with_bt_set exp, with_pass
      assert_with_bt_set exp, with_ignore
    end
  end

  class WithNestedBacktraceTests < UnitTests
    desc "`with_backtrace` method nested"

    let(:from_bt1)    { ["called_from_here 1", Factory.string] }
    let(:from_bt2)    { ["called_from_here 2", Factory.string] }
    let(:from_block2) { proc { ignore; fail; pass; skip "todo"; } }
    let(:from_block1) {
      from_bt    = from_bt2
      from_block = from_block2
      proc { with_backtrace(from_bt, &from_block) }
    }

    should "alter non-error block results' bt with nested wbt accrued first lines" do
      context1.fail "not affected"
      begin
        context1.with_backtrace(from_bt1, &from_block1)
      rescue Assert::Result::TestSkipped => e
        test_results1 << Assert::Result::Skip.for_test(test1, e)
      end

      assert_equal 5, test_results1.size
      norm_fail, with_ignore, with_fail, with_pass, _with_skip = test_results1

      assert_not_with_bt_set norm_fail

      exp = [from_bt1.first, from_bt2.first]
      assert_with_bt_set exp, with_ignore
      assert_with_bt_set exp, with_fail
      assert_with_bt_set exp, with_pass
      assert_with_bt_set exp, with_ignore
    end
  end

  class InspectTests < UnitTests
    desc "inspect method"
    subject { inspect1 }

    let(:inspect1)  { context1.inspect }

    should "just show the name of the class" do
      exp = "#<#{context1.class}>"
      assert_equal exp, subject
    end
  end
end
