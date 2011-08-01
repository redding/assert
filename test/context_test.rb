require 'test_belt'
require 'assert/context'

require 'assert/test'

class Assert::Context



  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "a context"
    subject do
      Assert::Context.new(Assert::Test.new("something", ::Proc.new {}))
    end

    should have_instance_methods :assert, :refute

    should "make assertions" do
      assert_nothing_raised do
        subject.assert(1==1)
      end
    end

    should "make refutations" do
      assert_nothing_raised do
        subject.refute(1==0)
      end
    end

  end



  class SkipTest < BasicTest

    should have_instance_methods :skip

    should "skip a test with a method call" do
      assert_raises Assert::Result::Skip do
        subject.skip
      end
    end

  end



  class PassTest < BasicTest

    should have_instance_methods :pass

    should "pass a test with a method call" do
      assert_raises Assert::Result::Pass do
        subject.pass
      end
    end

    should "pass asserts that are not false or nil" do
      assert_kind_of Assert::Result::Pass, subject.assert(34)
    end

    should "pass refutes that are false" do
      assert_kind_of Assert::Result::Pass, subject.refute(false)
    end

    should "pass refutes that are nil" do
      assert_kind_of Assert::Result::Pass, subject.refute(nil)
    end


  end



  class FailTest < BasicTest

    should have_instance_methods :fail, :flunk

    should "fail tests with a method call" do
      assert_raises Assert::Result::Fail do
        subject.fail
      end
    end

    should "fail tests with a method call and custom message" do
      begin
        subject.fail("your test failed")
      rescue Assert::Result::Fail => err
        assert_equal "your test failed", err.message
      end
    end

    should "flunk tests with a method call" do
      assert_raises Assert::Result::Fail do
        subject.flunk
      end
    end

    should "flunk tests with a method call and custom message" do
      begin
        subject.flunk("your assertion flunked")
      rescue Assert::Result::Fail => err
        assert_equal "your assertion flunked", err.message
      end
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

  end



end
