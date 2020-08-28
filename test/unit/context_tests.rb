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
    should have_cmeths :description, :desc, :describe, :subject, :suite, :let
    should have_cmeths :setup_once, :before_once, :startup
    should have_cmeths :teardown_once, :after_once, :shutdown
    should have_cmeths :setup, :before, :setups, :run_setups
    should have_cmeths :teardown, :after, :teardowns, :run_teardowns
    should have_cmeths :around, :arounds, :run_arounds
    should have_cmeths :test, :test_eventually, :test_skip
    should have_cmeths :should, :should_eventually, :should_skip

    should have_imeths :assert, :assert_not, :refute, :assert_that
    should have_imeths :pass, :ignore, :fail, :flunk, :skip
    should have_imeths :pending, :with_backtrace, :subject

    should "collect context info" do
      test = @__assert_running_test__
      assert_that(test.context_info.file).matches(/test\/unit\/context_tests.rb$/)
      assert_that(test.context_info.klass).equals(self.class)
    end

    private

    ASSERT_TEST_PATH_REGEX = /\A#{File.join(ROOT_PATH, "test", "")}/

    def assert_with_bt_set(exp_with_bt, result)
      with_backtrace(caller) do
        assert_that(result.with_bt_set?).is_true

        exp = Assert::Result::Backtrace.to_s(exp_with_bt+[(result.backtrace.filtered.first)])
        assert_that(result.trace).equals(exp)
        assert_that(result.src_line).equals(exp_with_bt.first)
      end
    end

    def assert_not_with_bt_set(result)
      with_backtrace(caller) do
        assert_that(result.with_bt_set?).is_false

        assert_that(result.trace).equals(result.src_line)
        assert_that(result.src_line).equals(result.backtrace.filtered.first.to_s)
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
      assert_that(@exception).is_kind_of(Assert::Result::TestSkipped)
      assert_that(@exception.message).equals(msg1)
      assert_that(subject.message).equals(msg1)
    end

    should "not call the result callback" do
      assert_that(@callback_result).is_nil
    end

    should "use any given called from arg as the exception backtrace" do
      assert_that(@exception.backtrace.size).does_not_equal(1)

      called_from = Factory.string
      begin; context1.skip(msg1, called_from); rescue StandardError => exception; end
      assert_that(exception.backtrace.size).equals(1)
      assert_that(exception.backtrace.first).equals(called_from)
    end
  end

  class IgnoreTests < UnitTests
    desc "ignore method"
    subject { @result }

    setup do
      @result = context1.ignore(msg1)
    end

    should "create an ignore result and set its message" do
      assert_that(subject).is_kind_of(Assert::Result::Ignore)
      assert_that(subject.message).equals(msg1)
    end

    should "call the result callback" do
      assert_that(@callback_result).equals(@result)
    end
  end

  class PassTests < UnitTests
    desc "pass method"
    subject { @result }

    setup do
      @result = context1.pass(msg1)
    end

    should "create a pass result and set its message" do
      assert_that(subject).is_kind_of(Assert::Result::Pass)
      assert_that(subject.message).equals(msg1)
    end

    should "call the result callback" do
      assert_that(@callback_result).equals(@result)
    end
  end

  class FlunkTests < UnitTests
    desc "flunk method"
    subject { @result }

    setup do
      @result = context1.flunk(msg1)
    end

    should "create a fail result and set its message" do
      assert_that(subject).is_kind_of(Assert::Result::Fail)
      assert_that(subject.message).equals(msg1)
    end

    should "call the result callback" do
      assert_that(@callback_result).equals(@result)
    end
  end

  class FailTests < UnitTests
    desc "fail method"
    subject { @result }

    setup do
      @result = context1.fail
    end

    should "create a fail result and set its backtrace" do
      assert_that(subject).is_kind_of(Assert::Result::Fail)
      assert_that(subject.trace).equals(subject.backtrace.filtered.first.to_s)
      assert_that(subject.backtrace).is_kind_of(Array)
    end

    should "set any given result message" do
      result = context1.fail(msg1)
      assert_that(result.message).equals(msg1)
    end

    should "call the result callback" do
      assert_that(@callback_result).equals(@result)
    end
  end

  class HaltOnFailTests < UnitTests
    desc "failing when halting on fails"
    subject { @result }

    let(:context1) { context_class1.new(test1, halt_config1, result_callback1) }

    should "raise an exception with the failure's message" do
      begin; context1.fail(msg1); rescue StandardError => err; end
      assert_that(err).is_kind_of(Assert::Result::TestFailure)
      assert_that(err.message).equals(msg1)

      result = Assert::Result::Fail.for_test(Factory.test("something"), err)
      assert_that(result.message).equals(msg1)
    end

    should "not call the result callback" do
      assert_that(@callback_result).is_nil
    end
  end

  class AssertTests < UnitTests
    desc "assert method"

    let(:what_failed) { Factory.string }

    should "return a pass result given a `true` assertion" do
      result = subject.assert(true, msg1){ what_failed }
      assert_that(result).is_kind_of(Assert::Result::Pass)
      assert_that(result.message).equals("")
    end

    should "return a fail result given a `false` assertion" do
      result = subject.assert(false, msg1){ what_failed }
      assert_that(result).is_kind_of(Assert::Result::Fail)
    end

    should "pp the assertion value in the fail message by default" do
      exp_def_what = "Failed assert: assertion was `#{Assert::U.show(false, test1.config)}`."
      result = subject.assert(false, msg1)

      assert_that(result.message).equals([msg1, exp_def_what].join("\n"))
    end

    should "use a custom fail message if one is given" do
      result = subject.assert(false, msg1){ what_failed }
      assert_that(result.message).equals([msg1, what_failed].join("\n"))
    end

    should "return a pass result given a \"truthy\" assertion" do
      assert_that(subject.assert(34)).is_kind_of(Assert::Result::Pass)
    end

    should "return a fail result gievn a `nil` assertion" do
      assert_that(subject.assert(nil)).is_kind_of(Assert::Result::Fail)
    end
  end

  class AssertNotTests < UnitTests
    desc "assert_not method"

    should "return a pass result given a `false` assertion" do
      result = subject.assert_not(false, msg1)
      assert_that(result).is_kind_of(Assert::Result::Pass)
      assert_that(result.message).equals("")
    end

    should "return a fail result given a `true` assertion" do
      result = subject.assert_not(true, msg1)
      assert_that(result).is_kind_of(Assert::Result::Fail)
    end

    should "pp the assertion value in the fail message by default" do
      exp_def_what = "Failed assert_not: assertion was `#{Assert::U.show(true, test1.config)}`."
      result = subject.assert_not(true, msg1)

      assert_that(result.message).equals([msg1, exp_def_what].join("\n"))
    end

    should "return a fail result given a \"truthy\" assertion" do
      assert_that(subject.assert_not(34)).is_kind_of(Assert::Result::Fail)
    end

    should "return a pass result given a `nil` assertion" do
      assert_that(subject.assert_not(nil)).is_kind_of(Assert::Result::Pass)
    end
  end

  class AssertThatTests < UnitTests
    desc "`assert_that` method"

    setup do
      Assert.stub_tap_on_call(Assert::ActualValue, :new) { |_, call|
        @actual_value_new_call = call
      }
    end

    let(:actual_value) { Factory.string }

    should "build an Assert::ActualValue" do
      assert_instance_of Assert::ActualValue, subject.assert_that(actual_value)
      assert_equal [actual_value], @actual_value_new_call.pargs
      assert_equal({ context: context1 },  @actual_value_new_call.kargs)
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
      assert_that(subject).equals(expected1)
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

      assert_that(test_results1.size).equals(4)
      norm_fail, norm_pass, pending_fail, pending_pass = test_results1

      assert_that(norm_fail).is_kind_of(Assert::Result::Fail)
      assert_that(norm_pass).is_kind_of(Assert::Result::Pass)

      assert_that(pending_fail).is_kind_of(Assert::Result::Skip)
      assert_that(pending_fail.message).includes("Pending fail")

      assert_that(pending_pass).is_kind_of(Assert::Result::Fail)
      assert_that(pending_pass.message).includes("Pending pass")
    end
  end

  class PendingWithHaltOnFailTests < PendingTests
    desc "when halting on fails"
    subject { @result }

    let(:context1) { context_class1.new(test1, halt_config1, result_callback1) }

    should "make fails skips and stop the test" do
      begin; context1.pending(&block1); rescue StandardError => err; end
      assert_that(err).is_kind_of(Assert::Result::TestSkipped)
      assert_that(err.message).includes("Pending fail")

      assert_that(test_results1.size).equals(0) # it halted before the pending pass
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

      assert_that(test_results1.size).equals(5)
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

      assert_that(test_results1.size).equals(5)
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
      assert_that(subject).equals(exp)
    end
  end
end
