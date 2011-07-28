require 'test_belt'
require 'assert/test'

class Assert::Test

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "a Test"
    subject { Assert::Test.new("should do stuff") {} }

    should have_readers :name, :assertions

    should "know its name" do
      assert_equal "should do stuff", subject.name
    end

    should "have no assertions" do
      assert_equal [], subject.assertions
    end

  end

  class AssertionsTest < Test::Unit::TestCase
    include TestBelt

    context "a Test with assertions: pass, fail, skip, error"
    subject do
      Assert::Test.new("should assert stuff") do
        assert { 1 == 1 }
        assert { 1 == 0 }
        assert {  }
        assert { raise ArgumentError }
      end
    end

    should "have 4 assertions" do
      skip
      assert_equal 4, subject.assertions.size
    end

    should "pass its first assertion" do
      skip
      assert_kind_of Asset::Result::Pass, subject.assertions[0].result
    end

    should "fail its second assertion" do
      skip
      assert_kind_of Assert::Result::Fail, subject.assertions[1].result
    end

    should "skip its third assertion" do
      skip
      assert_kind_of Assert::Result::Skip, subject.assertions[2].result
    end

    should "error its fourth assertion" do
      skip
      assert_kind_of Assert::Result::Error, subject.assertions[3].result
    end

  end

end