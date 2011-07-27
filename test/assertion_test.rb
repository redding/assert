require 'test_belt'
require 'assert/assertion'

class Assert::Assertion

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "an assertion"
    subject { Assert::Assertion.new {} }

    should have_reader :statement
    should have_accessor :fail_msg
    should have_instance_methods :value, :result

    should "have no fail message by default" do
      assert_equal "", subject.fail_msg
    end

    should "write and know its fail message" do
      subject.fail_msg = "something failed"
      assert_equal "something failed", subject.fail_msg
    end

    should "have a Proc statement" do
      assert_kind_of ::Proc, subject.statement
    end

  end

  class TrueTest < Test::Unit::TestCase
    include TestBelt

    context "a true assertion"
    subject { Assert::Assertion.new("is not true") { 1 == 1 } }

    should "be true" do
      assert_equal true, subject.value
    end

    should "pass" do
      assert_kind_of Assert::Result::Pass, subject.result
    end

  end

  class FalseTest < Test::Unit::TestCase
    include TestBelt

    context "a false assertion"
    subject { Assert::Assertion.new("is not true") { 1 == 0 } }

    should "be false" do
      assert_equal false, subject.value
    end

    should "fail" do
      assert_kind_of Assert::Result::Fail, subject.result
    end

  end

  class NilTest < Test::Unit::TestCase
    include TestBelt

    context "a nil assertion"
    subject { Assert::Assertion.new("is not true") {  } }

    should "be nil" do
      assert_equal nil, subject.value
    end

    should "fail" do
      assert_kind_of Assert::Result::Skip, subject.result
    end

  end

  class ExceptionTest < Test::Unit::TestCase
    include TestBelt

    context "an assertion that raises an exception"
    subject do
      Assert::Assertion.new() { raise NoMethodError }
    end

    should "have no value" do
      assert_raises(NoMethodError) { subject.value }
    end

    should "fail" do
      assert_kind_of Assert::Result::Error, subject.result
    end

  end

end
