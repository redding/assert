require 'test/helper'

class Assert::Context::BasicTest < Assert::Context
  desc "Assert context"
  setup do
    @test = Factory.test
    @context_class = @test.context_class
    @context = @context_class.new(@test)
  end
  subject{ @context }

  INSTANCE_METHODS = [
    :assert, :assert_not, :refute,
    :skip, :pass, :fail, :flunk, :ignore,
    :subject
  ]
  INSTANCE_METHODS.each do |method|
    should "respond to the instance method ##{method}" do
      assert_respond_to subject, method
    end
  end

  teardown do
    TEST_ASSERT_SUITE.clear
  end
  
  

  class SkipTest < BasicTest
    desc "skip method"
    setup do
      @skip_msg = "I need to implement this in the future."
      begin
        @context.skip(@skip_msg)
      rescue Exception => @exception
      end
      @result = Factory.skip_result("something", @exception)
    end
    subject{ @result }

    should "raise a test skipped exception when called" do
      assert_kind_of Assert::Result::TestSkipped, @exception
    end
    should "raise the exception with the message passed to it" do
      assert_equal @skip_msg, @exception.message
    end
    should "set the message passed to it on the result" do
      assert_equal @skip_msg, subject.message
    end

  end



  class IgnoreTest < BasicTest
    desc "ignore method"
    setup do
      @ignore_msg = "Ignore this for now, will do later."
      @result = @context.ignore(@ignore_msg)
    end
    subject{ @result }

    should "create an ignore result" do
      assert_kind_of Assert::Result::Ignore, subject
    end
    should "set the messaged passed to it on the result" do
      assert_equal @ignore_msg, subject.message
    end

  end



  class PassTest < BasicTest
    desc "pass method"
    setup do
      @pass_msg = "That's right, it works."
      @result = @context.pass(@pass_msg)
    end
    subject{ @result }

    should "create a pass result" do
      assert_kind_of Assert::Result::Pass, subject
    end
    should "set the messaged passed to it on the result" do
      assert_equal @pass_msg, subject.message
    end

  end



  class FailTest < BasicTest
    desc "fail method"
    setup do
      @result = @context.fail
    end
    subject{ @result }

    should "create a fail result" do
      assert_kind_of Assert::Result::Fail, subject
    end
    should "set the calling backtrace on the result" do
      assert_kind_of Array, subject.backtrace
      assert_match /assert\/context\.rb/, subject.trace
    end

    class StringMessageTest < FailTest
      desc "with a string message"
      setup do
        @fail_msg = "Didn't work"
        @result = @context.fail(@fail_msg)
      end

      should "set the message passed to it on the result" do
        assert_equal @fail_msg, subject.message
      end

    end

    class ProcMessageTest < FailTest
      desc "with a proc message"
      setup do
        @fail_msg = lambda{ "Still didn't work" }
        @result = @context.fail(@fail_msg)
      end

      should "set the message passed to it on the result" do
        assert_equal @fail_msg.call, subject.message
      end

    end

  end

  class FlunkTest < BasicTest
    desc "flunk method"
    setup do
      @flunk_msg = "It flunked."
      @result = @context.flunk(@flunk_msg)
    end
    subject{ @result }

    should "create a fail result" do
      assert_kind_of Assert::Result::Fail, subject
    end
    should "set the message passed to it on the result" do
      assert_equal @flunk_msg, subject.message
    end

  end

end

=begin

TODO: move to tests for hte assert method
should "pass asserts that are not false or nil" do
  assert_kind_of Assert::Result::Pass, subject.assert(34)
end
should "pass refutes that are false" do
  assert_kind_of Assert::Result::Pass, subject.refute(false)
end
should "pass refutes that are nil" do
  assert_kind_of Assert::Result::Pass, subject.refute(nil)
end
should "fail asserts that are false" do
  assert_kind_of Assert::Result::Fail, subject.assert(false)
end
should "fail asserts that are nil" do
  assert_kind_of Assert::Result::Fail, subject.assert(nil)
end
should "fail refutes that are not false or nil" do
  assert_kind_of Assert::Result::Fail, subject.refute(34)
end

=end
