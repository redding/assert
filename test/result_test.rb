require 'test_belt'

require 'assert/result'

module Assert::Result
  class BaseTest < Test::Unit::TestCase
    include TestBelt

    context "a base result"
    subject { Assert::Result::Base.new }

    should have_readers :message, :abbrev, :to_sym

    RESULTS = [:pass?, :fail?, :error?, :skip?]
    should have_instance_methods *RESULTS

    RESULTS.each do |meth|
      should "not be #{meth}" do
        assert_equal false, subject.send(meth)
      end
    end

    should "be a RuntimeError" do
      assert_kind_of RuntimeError, subject
    end

  end

  class PassTest < Test::Unit::TestCase
    include TestBelt

    context "a pass result"
    subject { Assert::Result::Pass.new "passed" }

    should "be pass?" do
      assert_equal true, subject.pass?
    end

    NOT_RESULTS = [:fail?, :error?, :skip?]
    NOT_RESULTS.each do |meth|
      should "not be #{meth}" do
        assert_equal false, subject.send(meth)
      end
    end

    should "show '.' for its abbrev" do
      assert_equal '.', subject.abbrev
    end

    should "know its to_sym" do
      assert_equal :passed, subject.to_sym
    end
  end

  class FailTest < Test::Unit::TestCase
    include TestBelt

    context "a fail result"
    subject { Assert::Result::Fail.new "failed" }

    should "be fail?" do
      assert_equal true, subject.fail?
    end

    NOT_RESULTS = [:pass?, :error?, :skip?]
    NOT_RESULTS.each do |meth|
      should "not be #{meth}" do
        assert_equal false, subject.send(meth)
      end
    end

    should "show 'F' for its abbrev" do
      assert_equal 'F', subject.abbrev
    end

    should "know its to_sym" do
      assert_equal :failed, subject.to_sym
    end
  end

  class ErrorTest < Test::Unit::TestCase
    include TestBelt

    context "an error result"
    subject { Assert::Result::Error.new "errored" }

    should "be error?" do
      assert_equal true, subject.error?
    end

    NOT_RESULTS = [:pass?, :fail?, :skip?]
    NOT_RESULTS.each do |meth|
      should "not be #{meth}" do
        assert_equal false, subject.send(meth)
      end
    end

    should "show 'E' for its abbrev" do
      assert_equal 'E', subject.abbrev
    end

    should "know its to_sym" do
      assert_equal :errored, subject.to_sym
    end
  end

  class SkipTest < Test::Unit::TestCase
    include TestBelt

    context "a skip result"
    subject { Assert::Result::Skip.new "skipped" }

    should "be skip?" do
      assert_equal true, subject.skip?
    end

    NOT_RESULTS = [:pass?, :fail?, :error?]
    NOT_RESULTS.each do |meth|
      should "not be #{meth}" do
        assert_equal false, subject.send(meth)
      end
    end

    should "show 'S' for its abbrev" do
      assert_equal 'S', subject.abbrev
    end

    should "know its to_sym" do
      assert_equal :skipped, subject.to_sym
    end
  end

end
