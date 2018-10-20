require "assert"
require "assert/assertions"

require "assert/utils"

module Assert::Assertions

  class AssertTrueTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_true`"
    setup do
      desc = @desc = "assert true fail desc"
      args = @args = ["whatever", desc]
      @test = Factory.test do
        assert_true(true)  # pass
        assert_true(*args) # fail
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
      exp = "#{@args[1]}\nExpected #{Assert::U.show(@args[0], @c)} to be true."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

  class AssertNotTrueTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_true`"
    setup do
      desc = @desc = "assert not true fail desc"
      args = @args = [true, desc]
      @test = Factory.test do
        assert_not_true(false) # pass
        assert_not_true(*args) # fail
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
      exp = "#{@args[1]}\nExpected #{Assert::U.show(@args[0], @c)} to not be true."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

  class AssertFalseTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_false`"
    setup do
      desc = @desc = "assert false fail desc"
      args = @args = ["whatever", desc]
      @test = Factory.test do
        assert_false(false) # pass
        assert_false(*args) # fail
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
      exp = "#{@args[1]}\nExpected #{Assert::U.show(@args[0], @c)} to be false."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

  class AssertNotFalseTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_false`"
    setup do
      desc = @desc = "assert not false fail desc"
      args = @args = [false, desc]
      @test = Factory.test do
        assert_not_false(true)  # pass
        assert_not_false(*args) # fail
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
      exp = "#{@args[1]}\nExpected #{Assert::U.show(@args[0], @c)} to not be false."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

end
