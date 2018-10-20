require "assert"
require "assert/assertions"

require "assert/utils"

module Assert::Assertions

  class AssertInstanceOfTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_instance_of`"
    setup do
      desc = @desc = "assert instance of fail desc"
      args = @args = [Array, "object", desc]
      @test = Factory.test do
        assert_instance_of(String, "object") # pass
        assert_instance_of(*args)            # fail
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
      exp = "#{@args[2]}\nExpected #{Assert::U.show(@args[1], @c)} (#{@args[1].class})"\
            " to be an instance of #{@args[0]}."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

  class AssertNotInstanceOfTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_instance_of`"
    setup do
      desc = @desc = "assert not instance of fail desc"
      args = @args = [String, "object", desc]
      @test = Factory.test do
        assert_not_instance_of(*args)           # fail
        assert_not_instance_of(Array, "object") # pass
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
      exp = "#{@args[2]}\nExpected #{Assert::U.show(@args[1], @c)} (#{@args[1].class})"\
            " to not be an instance of #{@args[0]}."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

end

