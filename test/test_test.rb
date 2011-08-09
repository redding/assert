require 'test_belt'
require 'assert/test'

require 'assert/context'
require 'assert/suite'

class Assert::Test

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "a Test"
    subject do
      Assert::Test.new("should do stuff", ::Proc.new {}, Assert::Context)
    end

    should have_readers :name, :code, :context
    should have_accessor :results
    should have_instance_methods :run, :result_count, :assertion_result

    should "know its name" do
      assert_equal "should do stuff", subject.name
    end

    should "have zero results before running" do
      assert_equal 0, subject.result_count
    end

  end

  class ResultTest < Test::Unit::TestCase
    include TestBelt

    context "that runs"
    before do
      Assert::Suite[{Assert::Context => [subject]}].tests.each do |test|
        @test_run_results = test.run
      end
    end
  end

  class NothingTest < ResultTest
    context "and does nothing"
    subject do
      Assert::Test.new("should assert stuff", ::Proc.new do
      end, Assert::Context)
    end

    should "have 0 results" do
      assert_equal 0, subject.result_count
      assert_equal subject.result_count, @test_run_results.size
    end

  end

  class PassTest < ResultTest
    context "and passes a single assertion"
    subject do
      Assert::Test.new("should assert stuff", ::Proc.new do
        assert(1 == 1)
      end, Assert::Context)
    end

    should "have 1 result" do
      assert_equal 1, subject.result_count
      assert_equal subject.result_count, @test_run_results.size
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
      end, Assert::Context)
    end

    should "have 1 result" do
      assert_equal 1, subject.result_count
      assert_equal subject.result_count, @test_run_results.size
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
      end, Assert::Context)
    end

    should "have 1 result" do
      assert_equal 1, subject.result_count
      assert_equal subject.result_count, @test_run_results.size
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
      end, Assert::Context)
    end

    should "have 1 result" do
      assert_equal 1, subject.result_count
      assert_equal subject.result_count, @test_run_results.size
    end

    should "have a errored result" do
      assert_kind_of Assert::Result::Error, subject.results.first
    end
  end

  class MixedTest < ResultTest
    context "and has 1 pass and 1 fail assertion"
    subject do
      Assert::Test.new("should assert stuff", ::Proc.new do
        assert(1 == 1)
        assert(1 == 0)
      end, Assert::Context)
    end

    should "have 2 total results" do
      assert_equal 2, subject.result_count
      assert_equal subject.result_count, @test_run_results.size
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

  end



  class MixedSkipTest < ResultTest
    context "and has 1 pass and 1 fail assertion with a skip call in between"
    subject do
      Assert::Test.new("should assert stuff", ::Proc.new do
        assert(1 == 1)
        skip
        assert(1 == 0)
      end, Assert::Context)
    end

    should "have a skip for its last result" do
      assert_kind_of Assert::Result::Skip, subject.results.last
    end

    should "have 2 total results" do
      assert_equal 2, subject.result_count
      assert_equal subject.result_count, @test_run_results.size
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 skip result" do
      assert_equal 1, subject.result_count(:skip)
    end

    should "have 0 fail results" do
      assert_equal 0, subject.result_count(:fail)
    end
  end


  class MixedErrorTest < ResultTest
    context "and has 1 pass and 1 fail assertion with an exception raised in between"
    subject do
      Assert::Test.new("should assert stuff", ::Proc.new do
        assert(1 == 1)
        raise Exception, "something errored"
        assert(1 == 0)
      end, Assert::Context)
    end

    should "have an error for its last result" do
      assert_kind_of Assert::Result::Error, subject.results.last
    end

    should "have 2 total results" do
      assert_equal 2, subject.result_count
      assert_equal subject.result_count, @test_run_results.size
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 error result" do
      assert_equal 1, subject.result_count(:error)
    end

    should "have 0 fail results" do
      assert_equal 0, subject.result_count(:fail)
    end
  end


  class MixedPassTest < ResultTest
    context "and has 1 pass and 1 fail assertion with a pass call in between"
    subject do
      Assert::Test.new("should assert stuff", ::Proc.new do
        assert(1 == 1)
        pass
        assert(1 == 0)
      end, Assert::Context)
    end

    should "have a pass for its last result" do
      assert_kind_of Assert::Result::Pass, subject.results.last
    end

    should "have 2 total results" do
      assert_equal 2, subject.result_count
      assert_equal subject.result_count, @test_run_results.size
    end

    should "have 2 pass results" do
      assert_equal 2, subject.result_count(:pass)
    end

    should "have 0 fail results" do
      assert_equal 0, subject.result_count(:fail)
    end

  end


  class MixedFailTest < ResultTest
    context "and has 1 pass and 1 fail assertion with a fail call in between"
    subject do
      Assert::Test.new("should assert stuff", ::Proc.new do
        assert(1 == 0)
        fail
        assert(1 == 1)
      end, Assert::Context)
    end

    should "have a fail for its last result" do
      assert_kind_of Assert::Result::Fail, subject.results.last
    end

    should "have 2 total results" do
      assert_equal 2, subject.result_count
      assert_equal subject.result_count, @test_run_results.size
    end

    should "have 0 pass results" do
      assert_equal 0, subject.result_count(:pass)
    end

    should "have 2 fail results" do
      assert_equal 2, subject.result_count(:fail)
    end

  end


  class MixedFlunkTest < ResultTest
    context "and has 1 pass and 1 fail assertion with a flunk call in between"
    subject do
      Assert::Test.new("should assert stuff", ::Proc.new do
        assert(1 == 0)
        flunk
        assert(1 == 1)
      end, Assert::Context)
    end

    should "have a fail for its last result" do
      assert_kind_of Assert::Result::Fail, subject.results.last
    end

    should "have 2 total results" do
      assert_equal 2, subject.result_count
      assert_equal subject.result_count, @test_run_results.size
    end

    should "have 0 pass results" do
      assert_equal 0, subject.result_count(:pass)
    end

    should "have 2 fail results" do
      assert_equal 2, subject.result_count(:fail)
    end

  end

  class WithSetupTest < Test::Unit::TestCase
    include TestBelt

    context "a Test that runs and has assertions that depend on a setup block"

    setup do
      Assert::Context.setup do # should probably create it's own context class
        @needed = true
      end
      subject.run
    end

    subject do
      Assert::Test.new("assert setup has run", ::Proc.new do
        assert(@needed)
      end, Assert::Context)
    end

    should "have 1 total result" do
      assert_equal 1, subject.result_count
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

  end

  class WithTeardownTest < Test::Unit::TestCase
    include TestBelt

    context "a Test that runs and has assertions that depend on a teardown block"

    setup do
      Assert::Context.teardown do # should probably create it's own context class
        raise("Teardown failed!")
      end
      subject.run
    end

    subject do
      Assert::Test.new("assert setup has run", ::Proc.new do
        # nothing needed
      end, Assert::Context)
    end

    should "have 1 total result" do
      assert_equal 1, subject.result_count
    end

    should "have 1 error result" do
      assert_equal 1, subject.result_count(:error)
    end

  end



end
