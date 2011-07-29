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

    should have_instance_methods :assert, :skip, :fail, :flunk

    should "make assertions" do
      assert_nothing_raised do
        subject.assert(1==1)
      end
    end

    should "fail assertions that are false" do
      assert_kind_of Assert::Result::Fail, subject.assert(false)
    end

    should "fail assertions that are nil" do
      assert_kind_of Assert::Result::Fail, subject.assert(nil)
    end

    should "fail assertions that are otherwise not true" do
      assert_kind_of Assert::Result::Fail, subject.assert(34)
    end

    should "fail assertions that are false with a message" do
      assert_equal "<false> is not true", subject.assert(false).message
    end

    should "fail assertions with a method call" do
      assert_raises Assert::Result::Fail do
        subject.fail
      end
    end

    should "flunk assertions with a method call" do
      assert_raises Assert::Result::Fail do
        subject.flunk
      end
    end

    should "be able to fail assertions with a custom message" do
      message = subject.assert(false, "your assertion was false").message
      assert_equal "your assertion was false", message
    end

    should "be able to fail assertions with a method call and custom message" do
      begin
        subject.fail("your assertion was false")
      rescue Assert::Result::Fail => err
        assert_equal "your assertion was false", err.message
      end
    end

    should "be able to flunk assertions with a method call and custom message" do
      begin
        subject.flunk("your assertion was false")
      rescue Assert::Result::Fail => err
        assert_equal "your assertion was false", err.message
      end
    end

  end

end
