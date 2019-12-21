require "assert"
require "assert/assertions"

require "assert/utils"

module Assert::Assertions
  class AssertIncludesTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_includes`"
    setup do
      desc = @desc = "assert includes fail desc"
      args = @args = [2, [1], desc]
      @test = Factory.test do
        assert_includes(1, [1]) # pass
        assert_includes(*args)    # fail
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
      exp = "#{@args[2]}\n"\
            "Expected #{Assert::U.show(@args[1], @c)}"\
            " to include #{Assert::U.show(@args[0], @c)}."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end

  class AssertNotIncludedTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_included`"
    setup do
      desc = @desc = "assert not included fail desc"
      args = @args = [1, [1], desc]
      @test = Factory.test do
        assert_not_included(2, [1]) # pass
        assert_not_included(*args)    # fail
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
      exp = "#{@args[2]}\n"\
            "Expected #{Assert::U.show(@args[1], @c)}"\
            " to not include #{Assert::U.show(@args[0], @c)}."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end
end

