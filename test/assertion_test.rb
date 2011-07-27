require 'test_belt'
require 'assert/assertion'

class Assert::Assertion
  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "a basic (empty) assertion"
    subject { Assert::Assertion.new {} }

    should have_readers :statement, :description, :result

    should "have no description" do
      assert_equal "", subject.description
    end

    should "have a Proc statement" do
      assert_kind_of ::Proc, subject.statement
    end

    should "know its description" do
      asrt = Assert::Assertion.new("an assertion") {}
      assert_equal "an assertion", asrt.description
    end

    should "be skipped" do
      assert_kind_of Assert::Result::Skip, subject.result
    end

  end
end
