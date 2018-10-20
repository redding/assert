require "assert"

class Assert::Test

  class SystemTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "Assert::Test"
    subject{ @test }

  end

  class NoResultsTests < SystemTests
    desc "when producing no results"
    setup do
      @test = Factory.test
      @test.run(&test_run_callback)
    end

    should "generate 0 results" do
      assert_equal 0, test_run_result_count
    end

  end

  class PassTests < SystemTests
    desc "when passing a single assertion"
    setup do
      @test = Factory.test{ assert(1 == 1) }
      @test.run(&test_run_callback)
    end

    should "generate 1 result" do
      assert_equal 1, test_run_result_count
    end

    should "generate 1 pass result" do
      assert_equal 1, test_run_result_count(:pass)
    end

  end

  class FailTests < SystemTests
    desc "when failing a single assertion"
    setup do
      @test = Factory.test{ assert(1 == 0) }
      @test.run(&test_run_callback)
    end

    should "generate 1 result" do
      assert_equal 1, test_run_result_count
    end

    should "generate 1 fail result" do
      assert_equal 1, test_run_result_count(:fail)
    end

  end

  class SkipTests < SystemTests
    desc "when skipping once"
    setup do
      @test = Factory.test{ skip }
      @test.run(&test_run_callback)
    end

    should "generate 1 result" do
      assert_equal 1, test_run_result_count
    end

    should "generate 1 skip result" do
      assert_equal 1, test_run_result_count(:skip)
    end

  end

  class ErrorTests < SystemTests
    desc "when erroring once"
    setup do
      @test = Factory.test{ raise("WHAT") }
      @test.run(&test_run_callback)
    end

    should "generate 1 result" do
      assert_equal 1, test_run_result_count
    end

    should "generate 1 error result" do
      assert_equal 1, test_run_result_count(:error)
    end

  end

  class MixedTests < SystemTests
    desc "when passing 1 assertion and failing 1 assertion"
    setup do
      @test = Factory.test do
        assert(1 == 1)
        assert(1 == 0)
      end
      @test.run(&test_run_callback)
    end

    should "generate 2 total results" do
      assert_equal 2, test_run_result_count
    end

    should "generate 1 pass result" do
      assert_equal 1, test_run_result_count(:pass)
    end

    should "generate 1 fail result" do
      assert_equal 1, test_run_result_count(:fail)
    end

  end

  class MixedSkipTests < SystemTests
    desc "when passing 1 assertion and failing 1 assertion with a skip call in between"
    setup do
      @test = Factory.test do
        assert(1 == 1)
        skip
        assert(1 == 0)
      end
      @test.run(&test_run_callback)
    end

    should "generate 2 total results" do
      assert_equal 2, test_run_result_count
    end

    should "generate a skip for its last result" do
      assert_kind_of Assert::Result::Skip, last_test_run_result
    end

    should "generate 1 pass result" do
      assert_equal 1, test_run_result_count(:pass)
    end

    should "generate 1 skip result" do
      assert_equal 1, test_run_result_count(:skip)
    end

    should "generate 0 fail results" do
      assert_equal 0, test_run_result_count(:fail)
    end

  end

  class MixedErrorTests < SystemTests
    desc "when passing 1 assertion and failing 1 assertion with an exception raised in between"
    setup do
      @test = Factory.test do
        assert(1 == 1)
        raise Exception, "something errored"
        assert(1 == 0)
      end
      @test.run(&test_run_callback)
    end

    should "generate 2 total results" do
      assert_equal 2, test_run_result_count
    end

    should "generate an error for its last result" do
      assert_kind_of Assert::Result::Error, last_test_run_result
    end

    should "generate 1 pass result" do
      assert_equal 1, test_run_result_count(:pass)
    end

    should "generate 1 error result" do
      assert_equal 1, test_run_result_count(:error)
    end

    should "generate 0 fail results" do
      assert_equal 0, test_run_result_count(:fail)
    end

  end

  class MixedPassTests < SystemTests
    desc "when passing 1 assertion and failing 1 assertion with a pass call in between"
    setup do
      @test = Factory.test do
        assert(1 == 1)
        pass
        assert(1 == 0)
      end
      @test.run(&test_run_callback)
    end

    should "generate 3 total results" do
      assert_equal 3, test_run_result_count
    end

    should "generate a fail for its last result" do
      assert_kind_of Assert::Result::Fail, last_test_run_result
    end

    should "generate 2 pass results" do
      assert_equal 2, test_run_result_count(:pass)
    end

    should "generate 1 fail result" do
      assert_equal 1, test_run_result_count(:fail)
    end

  end

  class MixedFailTests < SystemTests
    desc "when failing 1 assertion and passing 1 assertion with a fail call in between"
    setup do
      @test = Factory.test do
        assert(1 == 0)
        fail
        assert(1 == 1)
      end
      @test.run(&test_run_callback)
    end

    should "generate 3 total results" do
      assert_equal 3, test_run_result_count
    end

    should "generate a pass for its last result" do
      assert_kind_of Assert::Result::Pass, last_test_run_result
    end

    should "generate 1 pass result" do
      assert_equal 1, test_run_result_count(:pass)
    end

    should "generate 2 fail results" do
      assert_equal 2, test_run_result_count(:fail)
    end

  end

  class MixedFlunkTests < SystemTests
    desc "has failing 1 assertion and passing 1 assertion with a flunk call in between"
    setup do
      @test = Factory.test do
        assert(1 == 0)
        flunk
        assert(1 == 1)
      end
      @test.run(&test_run_callback)
    end

    should "generate 3 total results" do
      assert_equal 3, test_run_result_count
    end

    should "generate a pass for its last result" do
      assert_kind_of Assert::Result::Pass, last_test_run_result
    end

    should "generate 1 pass results" do
      assert_equal 1, test_run_result_count(:pass)
    end

    should "generate 2 fail results" do
      assert_equal 2, test_run_result_count(:fail)
    end

  end

  class WithSetupsTests < SystemTests
    desc "that has setup logic"
    setup do
      @context_class = Factory.context_class do
        # assert style
        setup{ pass "assert style setup" }
        # test/unit style
        def setup; pass "test/unit style setup"; end
      end
      @test = Factory.test("t", Factory.context_info(@context_class)){ pass "TEST" }
      @test.run(&test_run_callback)
    end

    should "execute all setup logic when run" do
      assert_equal 3, test_run_result_count(:pass)

      exp = ["assert style setup", "test/unit style setup", "TEST"]
      assert_equal exp, test_run_result_messages
    end

  end

  class WithTeardownsTests < SystemTests
    desc "that has teardown logic"
    setup do
      @context_class = Factory.context_class do
        # assert style
        teardown{ pass "assert style teardown" }
        # test/unit style
        def teardown; pass "test/unit style teardown"; end
      end
      @test = Factory.test("t", Factory.context_info(@context_class)){ pass "TEST" }
      @test.run(&test_run_callback)
    end

    should "execute all teardown logic when run" do
      assert_equal 3, test_run_result_count(:pass)

      exp = ["TEST", "assert style teardown", "test/unit style teardown"]
      assert_equal exp, test_run_result_messages
    end

  end

  class WithAroundsTests < SystemTests
    desc "that has around logic (in addition to setups/teardowns)"
    setup do
      @parent_context_class = Factory.modes_off_context_class do
        around do |block|
          pass "parent around start"
          block.call
          pass "parent around end"
        end
        setup{ pass "parent setup" }
        teardown{ pass "parent teardown" }
      end
      @context_class = Factory.modes_off_context_class(@parent_context_class) do
        setup{ pass "child setup1" }
        around do |block|
          pass "child around1 start"
          block.call
          pass "child around1 end"
        end
        teardown{ pass "child teardown1" }
        setup{ pass "child setup2" }
        around do |block|
          pass "child around2 start"
          block.call
          pass "child around2 end"
        end
        teardown{ pass "child teardown2" }
      end
      @test = Factory.test("t", Factory.context_info(@context_class)){ pass "TEST" }
      @test.run(&test_run_callback)
    end

    should "run the arounds outside of the setups/teardowns/test" do
      assert_equal 13, test_run_result_count(:pass)

      exp = [
        "parent around start", "child around1 start", "child around2 start",
        "parent setup", "child setup1", "child setup2", "TEST",
        "child teardown1", "child teardown2", "parent teardown",
        "child around2 end", "child around1 end", "parent around end"
      ]
      assert_equal exp, test_run_result_messages
    end

  end

end
