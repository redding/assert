require "assert"
require "assert/assertions"

require "assert/utils"

module Assert::Assertions

  class AssertMatchTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_match`"
    setup do
      desc = @desc = "assert match fail desc"
      args = @args = ["not", "a string", desc]
      @test = Factory.test do
        assert_match(/a/, "a string") # pass
        assert_match(*args)           # fail
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
      exp = "#{@args[2]}\nExpected #{Assert::U.show(@args[1], @c)}"\
            " to match #{Assert::U.show(@args[0], @c)}."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

  class AssertNotMatchTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_match`"
    setup do
      desc = @desc = "assert not match fail desc"
      args = @args = [/a/, "a string", desc]
      @test = Factory.test do
        assert_not_match(*args)             # fail
        assert_not_match("not", "a string") # pass
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
      exp = "#{@args[2]}\nExpected #{Assert::U.show(@args[1], @c)}"\
            " to not match #{Assert::U.show(@args[0], @c)}."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

end

