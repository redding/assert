require 'assert'
require 'assert/context'

require 'assert/config'
require 'assert/utils'

class Assert::Context

  class UnitTests < Assert::Context
    desc "Assert context"
    setup do
      @test = Factory.test
      @context_class = @test.context_class
      @context = @context_class.new(@test, @test.config)
    end
    subject{ @context }

    # DSL methods
    should have_cmeths :description, :desc, :describe, :subject, :suite
    should have_cmeths :setup_once, :before_once, :startup
    should have_cmeths :teardown_once, :after_once, :shutdown
    should have_cmeths :setup, :before, :setups, :run_setups
    should have_cmeths :teardown, :after, :teardowns, :run_teardowns
    should have_cmeths :test, :test_eventually, :test_skip
    should have_cmeths :should, :should_eventually, :should_skip

    should have_imeths :assert, :assert_not, :refute
    should have_imeths :skip, :pass, :fail, :flunk, :ignore
    should have_imeths :with_backtrace, :subject

    def test_should_collect_context_info
      this = @__running_test__
      assert_match /test\/unit\/context_tests.rb$/, this.context_info.file
      assert_equal self.class, this.context_info.klass
    end

  end

  class SkipTests < UnitTests
    desc "skip method"
    setup do
      @skip_msg = "I need to implement this in the future."
      begin; @context.skip(@skip_msg); rescue Exception => @exception; end
      @result = Factory.skip_result("something", @exception)
    end
    subject{ @result }

    should "raise a test skipped exception and set its message" do
      assert_kind_of Assert::Result::TestSkipped, @exception
      assert_equal @skip_msg, @exception.message
      assert_equal @skip_msg, subject.message
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

  end

  class HaltOnFailTests < FailTests
    desc "when halting on fails"
    setup do
      @halt_config = Assert::Config.new(:halt_on_fail => true)
      @context = @context_class.new(@test, @halt_config)
      @fail_msg = "something failed"
    end
    subject{ @result }

    should "raise an exception with the failure's message" do
      err = begin
        @context.fail @fail_msg
      rescue Exception => exception
        exception
      end
      assert_kind_of Assert::Result::TestFailure, err
      assert_equal @fail_msg, err.message

      result = Assert::Result::Fail.new(Factory.test("something"), err)
      assert_equal @fail_msg, result.message
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
      assert_nil result.message
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
      assert_nil result.message
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
      @context = @context_class.new(@test, @test.config)
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
      @from_bt = ['called_from_here']
      @from_block = proc { ignore; fail; pass; skip 'todo' }
    end

    should "replace the fail results from the block with the given backtrace" do
      @context.fail 'not affected'
      begin
        @context.with_backtrace(@from_bt, &@from_block)
      rescue Assert::Result::TestSkipped => e
        @test.results << Assert::Result::Skip.new(@test, e)
      end

      assert_equal 5, @test.results.size
      norm_fail, with_ignore, with_fail, with_pass, with_skip = @test.results

      assert_not_equal @from_bt, norm_fail.backtrace
      assert_equal @from_bt, with_ignore.backtrace
      assert_equal @from_bt, with_fail.backtrace
      assert_equal @from_bt, with_pass.backtrace
      assert_equal @from_bt, with_skip.backtrace
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
