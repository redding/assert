require 'assert'

class Assert::Test

  class RunningTest < Assert::Context
    desc "Assert tests that are run"
    subject{ @test }
  end

  class NothingTest < RunningTest
    desc "and does nothing"
    setup do
      @test = Factory.test
      @test.run
    end

    should "have 0 results" do
      assert_equal 0, subject.result_count
    end

  end



  class PassTest < RunningTest
    desc "and passes a single assertion"
    setup do
      @test = Factory.test{ assert(1 == 1) }
      @test.run
    end

    should "have 1 result" do
      assert_equal 1, subject.result_count
    end
    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

  end



  class FailTest < RunningTest
    desc "and fails a single assertion"
    setup do
      @test = Factory.test{ assert(1 == 0) }
      @test.run
    end

    should "have 1 result" do
      assert_equal 1, subject.result_count
    end
    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

  end



  class SkipTest < RunningTest
    desc "and skips"
    setup do
      @test = Factory.test{ skip }
      @test.run
    end

    should "have 1 result" do
      assert_equal 1, subject.result_count
    end
    should "have 1 skip result" do
      assert_equal 1, subject.result_count(:skip)
    end

  end



  class ErrorTest < RunningTest
    desc "and errors"
    setup do
      @test = Factory.test{ raise("WHAT") }
      @test.run
    end

    should "have 1 result" do
      assert_equal 1, subject.result_count
    end
    should "have 1 error result" do
      assert_equal 1, subject.result_count(:error)
    end

  end



  class MixedTest < RunningTest
    desc "and has 1 pass and 1 fail assertion"
    setup do
      @test = Factory.test do
        assert(1 == 1)
        assert(1 == 0)
      end
      @test.run
    end

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end
    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end
    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

  end



  class MixedSkipTest < RunningTest
    desc "and has 1 pass and 1 fail assertion with a skip call in between"
    setup do
      @test = Factory.test do
        assert(1 == 1)
        skip
        assert(1 == 0)
      end
      @test.run
    end

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end
    should "have a skip for its last result" do
      assert_kind_of Assert::Result::Skip, subject.results.last
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



  class MixedErrorTest < RunningTest
    desc "and has 1 pass and 1 fail assertion with an exception raised in between"
    setup do
      @test = Factory.test do
        assert(1 == 1)
        raise Exception, "something errored"
        assert(1 == 0)
      end
      @test.run
    end

    should "have an error for its last result" do
      assert_kind_of Assert::Result::Error, subject.results.last
    end
    should "have 2 total results" do
      assert_equal 2, subject.result_count
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



  class MixedPassTest < RunningTest
    desc "and has 1 pass and 1 fail assertion with a pass call in between"
    setup do
      @test = Factory.test do
        assert(1 == 1)
        pass
        assert(1 == 0)
      end
      @test.run
    end

    should "have a pass for its last result" do
      assert_kind_of Assert::Result::Fail, subject.results.last
    end
    should "have 3 total results" do
      assert_equal 3, subject.result_count
    end
    should "have 2 pass results" do
      assert_equal 2, subject.result_count(:pass)
    end
    should "have 1 fail results" do
      assert_equal 1, subject.result_count(:fail)
    end

  end



  class MixedFailTest < RunningTest
    desc "and has 1 pass and 1 fail assertion with a fail call in between"
    setup do
      @test = Factory.test do
        assert(1 == 0)
        fail
        assert(1 == 1)
      end
      @test.run
    end

    should "have a fail for its last result" do
      assert_kind_of Assert::Result::Pass, subject.results.last
    end
    should "have 3 total results" do
      assert_equal 3, subject.result_count
    end
    should "have 1 pass results" do
      assert_equal 1, subject.result_count(:pass)
    end
    should "have 2 fail results" do
      assert_equal 2, subject.result_count(:fail)
    end

  end



  class MixedFlunkTest < RunningTest
    desc "and has 1 pass and 1 fail assertion with a flunk call in between"
    setup do
      @test = Factory.test do
        assert(1 == 0)
        flunk
        assert(1 == 1)
      end
      @test.run
    end

    should "have a fail for its last result" do
      assert_kind_of Assert::Result::Pass, subject.results.last
    end
    should "have 3 total results" do
      assert_equal 3, subject.result_count
    end
    should "have 1 pass results" do
      assert_equal 1, subject.result_count(:pass)
    end
    should "have 2 fail results" do
      assert_equal 2, subject.result_count(:fail)
    end

  end



  class WithSetupTest < RunningTest
    desc "a Test that runs and has assertions that depend on a setup block"
    setup do
      @context_class = Factory.context_class do
        setup{ @needed = true }
      end
      @test = Factory.test("something", @context_class) do
        assert(@needed)
      end
      @test.run
    end

    should "have 1 total result" do
      assert_equal 1, subject.result_count
    end
    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

  end



  class WithTeardownTest < RunningTest
    desc "a Test that runs and has assertions with a teardown block"
    setup do
      new_message = @new_message = "HOLLA"
      @context_class = Factory.context_class do
        teardown do
          pass_result = @__running_test__.pass_results.first
          pass_result.instance_variable_set("@message", new_message)
        end
      end
      @test = Factory.test("something amazing", @context_class) do
        assert(true)
      end
      @test.run
    end

    should "have 1 total result" do
      assert_equal 1, subject.result_count
    end
    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end
    should "have modifed the message" do
      assert_equal @new_message, subject.pass_results.first.message
    end

  end

end
