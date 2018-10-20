require "assert"
require "assert/assertions"

require "assert/utils"

module Assert::Assertions

  class AssertKindOfTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_kind_of`"
    setup do
      desc = @desc = "assert kind of fail desc"
      args = @args = [ Array, "object", desc ]
      @test = Factory.test do
        assert_kind_of(String, "object") # pass
        assert_kind_of(*args)            # fail
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
            " to be a kind of #{@args[0]}."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

  class AssertNotKindOfTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_kind_of`"
    setup do
      desc = @desc = "assert not kind of fail desc"
      args = @args = [ String, "object", desc ]
      @test = Factory.test do
        assert_not_kind_of(*args)           # fail
        assert_not_kind_of(Array, "object") # pass
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
            " to not be a kind of #{@args[0]}."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

end

