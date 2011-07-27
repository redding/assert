require 'test_belt'
require 'assert/test'

class Assert::Test

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "a Test"
    subject { Assert::Test.new("should do stuff") {} }

    should have_readers :name, :assertions
    should have_readers :setups, :teardowns

    should "know its name" do
      assert_equal "should do stuff", subject.name
    end

    should "have no assertions" do
      assert_equal [], subject.assertions
    end

    should "have no setups" do
      assert_equal [], subject.setups
    end

    should "have no teardowns" do
      assert_equal [], subject.teardowns
    end

  end

end