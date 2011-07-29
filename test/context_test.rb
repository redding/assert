require 'test_belt'
require 'assert/context'

class Assert::Context

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "a context"
    subject { Assert::Context.new }

    should have_instance_method :assert

    should "make assertions" do
      assert_nothing_raised do
        subject.assert(1==1)
      end
    end

    should "fail assertions that are not true" do
      assert_raises Assert::Result::Fail do
        subject.assert(false)
      end
      assert_raises Assert::Result::Fail do
        subject.assert(nil)
      end
      assert_raises Assert::Result::Fail do
        subject.assert(34)
      end
    end

    should "fail assertions with a message" do
      begin
        subject.assert(false)
      rescue Assert::Result::Fail => err
        assert_equal "<false> is not true", err.message
      end
    end

    should "be able to fail assertions with a custom message" do
      begin
        subject.assert(false, "your assertion was false")
      rescue Assert::Result::Fail => err
        assert_equal "your assertion was false", err.message
      end
    end

  end

end
