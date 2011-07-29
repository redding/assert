require 'test_belt'
require 'assert/test'

require 'assert/context'
require 'assert/suite'

class Assert::Test

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "a Test"
    subject { Assert::Test.new("should do stuff", ::Proc.new {}) }

    should have_readers :name, :code
    should have_accessor :results

    should "know its name" do
      assert_equal "should do stuff", subject.name
    end

  end

  class ResultTest < Test::Unit::TestCase
    include TestBelt

    context "that runs"
    before do
      Assert::Suite[{Assert::Context => [subject]}].run
    end
  end

  class NothingTest < ResultTest
    context "and does nothing"
    subject do
      Assert::Test.new("should assert stuff", ::Proc.new do
      end)
    end

    should "have 0 results" do
      assert_equal 0, subject.results.size
    end

  end

  class PassTest < ResultTest
    context "and passes a single assertion"
    subject do
      Assert::Test.new("should assert stuff", ::Proc.new do
        assert(1 == 1)
      end)
    end

    should "have 1 result" do
      assert_equal 1, subject.results.size
    end

    should "have a passing result" do
      assert_kind_of Assert::Result::Pass, subject.results.first
    end

  end

  class FailTest < ResultTest
    context "and fails a single assertion"
    subject do
      Assert::Test.new("should assert stuff", ::Proc.new do
        assert(1 == 0)
      end)
    end

    should "have 1 result" do
      assert_equal 1, subject.results.size
    end

    should "have a failing result" do
      assert_kind_of Assert::Result::Fail, subject.results.first
    end

  end

  class SkipTest < ResultTest
    context "and skips"
    subject do
      Assert::Test.new("should assert stuff", ::Proc.new do
        skip
      end)
    end

    should "have 1 result" do
      assert_equal 1, subject.results.size
    end

    should "have a skipped result" do
      assert_kind_of Assert::Result::Skip, subject.results.first
    end
  end

  class ErrorTest < ResultTest
    context "and fails"
    subject do
      Assert::Test.new("should assert stuff", ::Proc.new do
        raise Exception
      end)
    end

    should "have 1 result" do
      assert_equal 1, subject.results.size
    end

    should "have a errored result" do
      assert_kind_of Assert::Result::Error, subject.results.first
    end
  end

end
