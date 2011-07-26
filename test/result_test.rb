require 'test_belt'
require 'assert/result'

module Assert::Result
  class BaseTest < Test::Unit::TestCase
    include TestBelt

    context "a base result"
    subject { Assert::Result::Base.new "a result" }

    should have_readers :message

    RESULTS = [:pass?, :fail?, :error?, :skip?]
    should have_instance_methods *RESULTS

    RESULTS.each do |meth|
      should "not be #{meth}" do
        assert_equal false, subject.send(meth)
      end
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
  end

end
