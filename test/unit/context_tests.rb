require 'assert'
require 'assert/context'

class Assert::Context

  class BasicTests < Assert::Context
    desc "Assert context"
    setup do
      @test = Factory.test
      @context_class = @test.context_class
      @context = @context_class.new(@test)
    end
    teardown do
      TEST_ASSERT_SUITE.tests.clear
    end
    subject{ @context }

    should have_imeths :assert, :assert_not, :refute
    should have_imeths :skip, :pass, :fail, :flunk, :ignore
    should have_imeths :subject

    def test_should_collect_context_info
      this = @__running_test__
      assert_match /test\/unit\/context_tests.rb$/, this.context_info.file
      assert_equal self.class, this.context_info.klass
    end

  end

  class SkipTests < BasicTests
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

  class IgnoreTests < BasicTests
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

  class PassTests < BasicTests
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

  class FlunkTests < BasicTests
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

  class FailTests < BasicTests
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

    should "set any given result message evaluated from a proc" do
      fail_msg = ::Proc.new{ "Still didn't work" }
      result = @context.fail(fail_msg)
      assert_equal fail_msg.call, result.message
    end

  end

  class HaltOnFailTests < FailTests
    desc "when halting on fails"
    setup do
      @orig_halt_fail = Assert.config.halt_on_fail
      @fail_msg = "something failed"
    end
    teardown do
      Assert.config.halt_on_fail @orig_halt_fail
    end
    subject{ @result }

    should "raise an exception with the failure's message" do
      Assert.config.halt_on_fail true
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

  class AssertTests < BasicTests
    desc "assert method"
    setup do
      @fail_desc = "my fail desc"
      @what_failed = "what failed"
    end

    should "return a pass result given a `true` assertion" do
      result = subject.assert(true, @fail_desc, @what_failed)
      assert_kind_of Assert::Result::Pass, result
      assert_nil result.message
    end

    should "return a fail result given a `false` assertion" do
      result = subject.assert(false, @fail_desc, @what_failed)
      assert_kind_of Assert::Result::Fail, result
      assert_equal [@fail_desc, @what_failed].join("\n"), result.message
    end

    should "return a pass result given a \"truthy\" assertion" do
      assert_kind_of Assert::Result::Pass, subject.assert(34)
    end

    should "return a fail result gievn a `nil` assertion" do
      assert_kind_of Assert::Result::Fail, subject.assert(nil)
    end

  end

  class AssertNotTests < BasicTests
    desc "assert_not method"
    setup do
      @fail_desc = "my fail desc"
      @what_failed = "Failed assert_not: assertion was <true>."
    end

    should "return a fail result given a `true` assertion" do
      result = subject.assert_not(true, @fail_desc)
      assert_kind_of Assert::Result::Fail, result
      assert_equal [@fail_desc, @what_failed].join("\n"), result.message
    end

    should "return a pass result given a `false` assertion" do
      result = subject.assert_not(false, @fail_desc)
      assert_kind_of Assert::Result::Pass, result
      assert_nil result.message
    end

    should "return a fail result given a \"truthy\" assertion" do
      assert_kind_of Assert::Result::Fail, subject.assert_not(34)
    end

    should "return a pass result given a `nil` assertion" do
      assert_kind_of Assert::Result::Pass, subject.assert_not(nil)
    end

  end

  class SubjectTests < BasicTests
    desc "subject method"
    setup do
      expected = @expected = "amazing"
      @context_class = Factory.context_class do
        subject{ @something = expected }
      end
      @context = @context_class.new
      @subject = @context.subject
    end
    subject{ @subject }

    should "instance evaluate the block set with the class setup method" do
      assert_equal @expected, subject
    end

  end

  class InspectTests < BasicTests
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
