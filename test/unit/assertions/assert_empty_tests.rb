require "assert"
require "assert/assertions"

require "assert/utils"

module Assert::Assertions
  class AssertEmptyTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_empty`"
    setup do
      desc = @desc = "assert empty fail desc"
      args = @args = [[1], desc]
      @test = Factory.test do
        assert_empty([])    # pass
        assert_empty(*args) # fail
      end
      @c = @test.config
      @test.run(&test_run_callback)
    end
    subject{ @test }

    should "produce results as expected" do
      assert_equal 2, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 1, test_run_result_count(:fail)
    end

    should "have a fail message with custom and generic explanations" do
      exp = "#{@args[1]}\nExpected #{Assert::U.show(@args[0], @c)} to be empty."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

  class AssertNotEmptyTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_empty`"
    setup do
      desc = @desc = "assert not empty fail desc"
      args = @args = [[], desc]
      @test = Factory.test do
        assert_not_empty([1]) # pass
        assert_not_empty(*args) # fail
      end
      @c = @test.config
      @test.run(&test_run_callback)
    end
    subject{ @test }

    should "produce results as expected" do
      assert_equal 2, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 1, test_run_result_count(:fail)
    end

    should "have a fail message with custom and generic explanations" do
      exp = "#{@args[1]}\nExpected #{Assert::U.show(@args[0], @c)} to not be empty."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end
end
