require 'assert'

class RunningSystemTests < Assert::Context
  desc "Running a test (with no halt-on-fail) that"
  subject{ @test }

  class NothingTests < RunningSystemTests
    desc "does nothing"
    setup do
      @test = Factory.test
      @test.run
    end

    should "have 0 results" do
      assert_equal 0, subject.result_count
    end

  end

  class PassTests < RunningSystemTests
    desc "passes a single assertion"
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

  class FailTests < RunningSystemTests
    desc "fails a single assertion"
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

  class SkipTests < RunningSystemTests
    desc "skips once"
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

  class ErrorTests < RunningSystemTests
    desc "errors once"
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

  class MixedTests < RunningSystemTests
    desc "has 1 pass and 1 fail assertion"
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

  class MixedSkipTests < RunningSystemTests
    desc "has 1 pass and 1 fail assertion with a skip call in between"
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

  class MixedErrorTests < RunningSystemTests
    desc "has 1 pass and 1 fail assertion with an exception raised in between"
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

  class MixedPassTests < RunningSystemTests
    desc "has 1 pass and 1 fail assertion with a pass call in between"
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

  class MixedFailTests < RunningSystemTests
    desc "has 1 pass and 1 fail assertion with a fail call in between"
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

  class MixedFlunkTests < RunningSystemTests
    desc "has 1 pass and 1 fail assertion with a flunk call in between"
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

  class WithSetupsTests < RunningSystemTests
    desc "has tests that depend on setups"
    setup do
      assert_style_msg = @asm = "set by assert style setup"
      testunit_style_msg = @tusm = "set by test/unit style setup"
      @context_class = Factory.context_class do
        # assert style setup
        setup do
          # get msgs into test scope
          @assert_style_msg = assert_style_msg
          @testunit_style_msg = testunit_style_msg

          @setup_asm = @assert_style_msg
        end
        # classic test/unit style setup
        def setup; @setup_tusm = @testunit_style_msg; end
      end
      @test = Factory.test("something", Factory.context_info(@context_class)) do
        assert @assert_style_msg
        assert @testunit_style_msg

        @__running_test__.pass_results.first.
          instance_variable_set("@message", @setup_asm)

        @__running_test__.pass_results.last.
          instance_variable_set("@message", @setup_tusm)
      end
      @test.run
    end

    should "have a passing result for each setup type" do
      assert_equal 2, subject.result_count
      assert_equal 2, subject.result_count(:pass)
    end

    should "have run the assert style setup" do
      assert_equal @asm, subject.pass_results.first.message
    end

    should "have run the test/unit style setup" do
      assert_equal @tusm, subject.pass_results.last.message
    end

  end

  class WithTeardownsTests < RunningSystemTests
    desc "has tests that depend on teardowns"
    setup do
      assert_style_msg = @asm = "set by assert style teardown"
      testunit_style_msg = @tusm = "set by test/unit style teardown"
      @context_class = Factory.context_class do
        setup do
          # get msgs into test scope
          @assert_style_msg = assert_style_msg
          @testunit_style_msg = testunit_style_msg
        end
        # assert style teardown
        teardown do
          @__running_test__.pass_results.first.
            instance_variable_set("@message", @assert_style_msg)
        end
        # classic test/unit style teardown
        def teardown
          @__running_test__.pass_results.last.
            instance_variable_set("@message", @testunit_style_msg)
        end
      end
      @test = Factory.test("something amazing", Factory.context_info(@context_class)) do
        assert(true) # first pass result
        assert(true) # last pass result
      end
      @test.run
    end

    should "have a passing result for each teardown type" do
      assert_equal 2, subject.result_count
      assert_equal 2, subject.result_count(:pass)
    end

    should "have run the assert style teardown" do
      assert_equal @asm, subject.pass_results.first.message
    end

    should "have run test/unit style teardown" do
      assert_equal @tusm, subject.pass_results.last.message
    end

  end

  class WithAroundsTests < RunningSystemTests
    desc "has arounds (in addition to setups/teardowns)"
    setup do
      @parent_class = Factory.modes_off_context_class do
        around do |block|
          @__running_test__.output += "p-around start, "
          block.call
          @__running_test__.output += "p-around end."
        end
        setup{ @__running_test__.output += "p-setup, " }
        teardown{ @__running_test__.output += "p-teardown, " }
      end

      @context_class = Factory.modes_off_context_class(@parent_class) do
        attr_accessor :out_status

        setup{ @__running_test__.output += "c-setup1, " }
        around do |block|
          @__running_test__.output += "c-around1 start, "
          block.call
          @__running_test__.output += "c-around1 end, "
        end
        teardown{ @__running_test__.output += "c-teardown1, " }
        setup{ @__running_test__.output += "c-setup2, " }
        around do |block|
          @__running_test__.output += "c-around2 start, "
          block.call
          @__running_test__.output += "c-around2 end, "
        end
        teardown{ @__running_test__.output += "c-teardown2, " }
      end


      @test = Factory.test("something amazing", Factory.context_info(@context_class)) do
        @__running_test__.output += "TEST, "
      end
      @test.run
    end

    should "run the arounds outside of the setups/teardowns/test" do
      exp = "p-around start, c-around1 start, c-around2 start, "\
            "p-setup, c-setup1, c-setup2, "\
            "TEST, "\
            "c-teardown1, c-teardown2, p-teardown, "\
            "c-around2 end, c-around1 end, p-around end."
      assert_equal exp, subject.output
    end

  end

end
