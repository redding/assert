require 'assert'
require 'assert/context'

require 'assert/config'
require 'assert/result'
require 'assert/utils'

class Assert::Context

  class UnitTests < Assert::Context
    desc "Assert::Context"
    setup do
      @test = Factory.test
      @context_class = @test.context_class
      @callback_result = nil
      @test_results = []
      @result_callback = proc do |result|
        @callback_result = result
        @test_results << result
      end
      @context = @context_class.new(@test, @test.config, @result_callback)
    end
    subject{ @context }

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
    should have_imeths :skip, :pass, :fail, :flunk, :ignore
    should have_imeths :with_backtrace, :subject

    should "collect context info" do
      test = @__assert_running_test__
      assert_match /test\/unit\/context_tests.rb$/, test.context_info.file
      assert_equal self.class, test.context_info.klass
    end
    private

    ASSERT_TEST_PATH_REGEX = /\A#{File.join(ROOT_PATH, 'test', '')}/

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

        assert_equal result.src_line,                 result.trace
        assert_equal result.backtrace.filtered.first, result.src_line
      end
    end

  end

  class SkipTests < UnitTests
    desc "skip method"
    setup do
      @skip_msg = "I need to implement this in the future."
      begin; @context.skip(@skip_msg); rescue StandardError => @exception; end
      @result = Factory.skip_result(@exception)
    end
    subject{ @result }

    should "raise a test skipped exception and set its message" do
      assert_kind_of Assert::Result::TestSkipped, @exception
      assert_equal @skip_msg, @exception.message
      assert_equal @skip_msg, subject.message
    end

    should "not call the result callback" do
      assert_nil @callback_result
    end

    should "use any given called from arg as the exception backtrace" do
      assert_not_equal 1, @exception.backtrace.size

      called_from = Factory.string
      begin; @context.skip(@skip_msg, called_from); rescue StandardError => exception; end
      assert_equal 1,           exception.backtrace.size
      assert_equal called_from, exception.backtrace.first
    end

  end

  class IgnoreTests < UnitTests
    desc "ignore method"
    setup do
      @ignore_msg = "Ignore this for now, will do later."
      @result = @context.ignore(@ignore_msg)
    end
    subject{ @result }

    should "create an ignore result and set its message" do
      assert_kind_of Assert::Result::Ignore, subject
      assert_equal @ignore_msg, subject.message
    end

    should "call the result callback" do
      assert_equal @result, @callback_result
    end

  end

  class PassTests < UnitTests
    desc "pass method"
    setup do
      @pass_msg = "That's right, it works."
      @result = @context.pass(@pass_msg)
    end
    subject{ @result }

    should "create a pass result and set its message" do
      assert_kind_of Assert::Result::Pass, subject
      assert_equal @pass_msg, subject.message
    end

    should "call the result callback" do
      assert_equal @result, @callback_result
    end

  end

  class FlunkTests < UnitTests
    desc "flunk method"
    setup do
      @flunk_msg = "It flunked."
      @result = @context.flunk(@flunk_msg)
    end
    subject{ @result }

    should "create a fail result and set its message" do
      assert_kind_of Assert::Result::Fail, subject
      assert_equal @flunk_msg, subject.message
    end

    should "call the result callback" do
      assert_equal @result, @callback_result
    end

  end

  class FailTests < UnitTests
    desc "fail method"
    setup do
      @result = @context.fail
    end
    subject{ @result }

    should "create a fail result and set its backtrace" do
      assert_kind_of Assert::Result::Fail, subject
      assert_equal subject.backtrace.filtered.first, subject.trace
      assert_kind_of Array, subject.backtrace
    end

    should "set any given result message" do
      fail_msg = "Didn't work"
      result = @context.fail(fail_msg)
      assert_equal fail_msg, result.message
    end

    should "call the result callback" do
      assert_equal @result, @callback_result
    end

  end

  class HaltOnFailTests < UnitTests
    desc "failing when halting on fails"
    setup do
      @halt_config = Assert::Config.new(:halt_on_fail => true)
      @context = @context_class.new(@test, @halt_config, @result_callback)
      @fail_msg = "something failed"
    end
    subject{ @result }

    should "raise an exception with the failure's message" do
      begin; @context.fail(@fail_msg); rescue StandardError => err; end
      assert_kind_of Assert::Result::TestFailure, err
      assert_equal @fail_msg, err.message

      result = Assert::Result::Fail.for_test(Factory.test("something"), err)
      assert_equal @fail_msg, result.message
    end

    should "not call the result callback" do
      assert_nil @callback_result
    end

  end

  class AssertTests < UnitTests
    desc "assert method"
    setup do
      @fail_desc = "my fail desc"
      @what_failed = "what failed"
    end

    should "return a pass result given a `true` assertion" do
      result = subject.assert(true, @fail_desc){ @what_failed }
      assert_kind_of Assert::Result::Pass, result
      assert_equal '', result.message
    end

    should "return a fail result given a `false` assertion" do
      result = subject.assert(false, @fail_desc){ @what_failed }
      assert_kind_of Assert::Result::Fail, result
    end

    should "pp the assertion value in the fail message by default" do
      exp_def_what = "Failed assert: assertion was `#{Assert::U.show(false, @test.config)}`."
      result = subject.assert(false, @fail_desc)

      assert_equal [@fail_desc, exp_def_what].join("\n"), result.message
    end

    should "use a custom fail message if one is given" do
      result = subject.assert(false, @fail_desc){ @what_failed }
      assert_equal [@fail_desc, @what_failed].join("\n"), result.message
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
    setup do
      @fail_desc = "my fail desc"
    end

    should "return a pass result given a `false` assertion" do
      result = subject.assert_not(false, @fail_desc)
      assert_kind_of Assert::Result::Pass, result
      assert_equal '', result.message
    end

    should "return a fail result given a `true` assertion" do
      result = subject.assert_not(true, @fail_desc)
      assert_kind_of Assert::Result::Fail, result
    end

    should "pp the assertion value in the fail message by default" do
      exp_def_what = "Failed assert_not: assertion was `#{Assert::U.show(true, @test.config)}`."
      result = subject.assert_not(true, @fail_desc)

      assert_equal [@fail_desc, exp_def_what].join("\n"), result.message
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
    setup do
      expected = @expected = "amazing"
      @context_class = Factory.modes_off_context_class do
        subject{ @something = expected }
      end
      @context = @context_class.new(@test, @test.config, proc{ |result| })
      @subject = @context.subject
    end
    subject{ @subject }

    should "instance evaluate the block set with the class setup method" do
      assert_equal @expected, subject
    end

  end

  class WithBacktraceTests < UnitTests
    desc "with_backtrace method"
    setup do
      @from_bt    = ['called_from_here', Factory.string]
      @from_block = proc { ignore; fail; pass; skip 'todo'; }
    end

    should "alter non-error block results' bt with given bt's first line" do
      @context.fail 'not affected'
      begin
        @context.with_backtrace(@from_bt, &@from_block)
      rescue Assert::Result::TestSkipped => e
        @test_results << Assert::Result::Skip.for_test(@test, e)
      end

      assert_equal 5, @test_results.size
      norm_fail, with_ignore, with_fail, with_pass, with_skip = @test_results

      assert_not_with_bt_set norm_fail

      exp = [@from_bt.first]
      assert_with_bt_set exp, with_ignore
      assert_with_bt_set exp, with_fail
      assert_with_bt_set exp, with_pass
      assert_with_bt_set exp, with_ignore
    end

  end

  class WithNestedBacktraceTests < UnitTests
    desc "with_backtrace method nested"
    setup do
      @from_bt1            = ['called_from_here 1', Factory.string]
      @from_bt2 = from_bt2 = ['called_from_here 2', Factory.string]

      from_block2  = proc { ignore; fail; pass; skip 'todo'; }
      @from_block1 = proc { with_backtrace(from_bt2, &from_block2) }
    end

    should "alter non-error block results' bt with nested wbt accrued first lines" do
      @context.fail 'not affected'
      begin
        @context.with_backtrace(@from_bt1, &@from_block1)
      rescue Assert::Result::TestSkipped => e
        @test_results << Assert::Result::Skip.for_test(@test, e)
      end

      assert_equal 5, @test_results.size
      norm_fail, with_ignore, with_fail, with_pass, with_skip = @test_results

      assert_not_with_bt_set norm_fail

      exp = [@from_bt1.first, @from_bt2.first]
      assert_with_bt_set exp, with_ignore
      assert_with_bt_set exp, with_fail
      assert_with_bt_set exp, with_pass
      assert_with_bt_set exp, with_ignore
    end

  end

  class InspectTests < UnitTests
    desc "inspect method"
    setup do
      @expected = "#<#{@context.class}>"
      @inspect = @context.inspect
    end
    subject{ @inspect }

    should "just show the name of the class" do
      assert_equal @expected, subject
    end
  end

end
