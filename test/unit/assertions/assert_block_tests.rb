require "assert"
require "assert/assertions"

module Assert::Assertions

  class AssertBlockTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_block`"
    setup do
      desc = @desc = "assert block fail desc"
      @test = Factory.test do
        assert_block{ true }        # pass
        assert_block(desc){ false } # fail
      end
      @test.run(&test_run_callback)
    end
    subject{ @test }

    should "produce results as expected" do
      assert_equal 2, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 1, test_run_result_count(:fail)
    end

    should "have a fail message with custom and generic explanations" do
      exp = "#{@desc}\nExpected block to return a true value."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

  class AssertNotBlockTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_block`"
    setup do
      desc = @desc = "assert not block fail desc"
      @test = Factory.test do
        assert_not_block(desc){ true } # fail
        assert_not_block{ false }      # pass
      end
      @test.run(&test_run_callback)
    end
    subject{ @test }

    should "produce results as expected" do
      assert_equal 2, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 1, test_run_result_count(:fail)
    end

    should "have a fail message with custom and generic explanations" do
      exp = "#{@desc}\nExpected block to not return a true value."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

end

