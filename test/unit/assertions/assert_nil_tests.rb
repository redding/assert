require 'assert'
require 'assert/assertions'

require 'assert/utils'

module Assert::Assertions

  class AssertNilTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_nil`"
    setup do
      desc = @desc = "assert nil empty fail desc"
      args = @args = [ 1, desc ]
      @test = Factory.test do
        assert_nil(nil)   # pass
        assert_nil(*args) # fail
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
      exp = "#{@args[1]}\nExpected #{Assert::U.show(@args[0], @c)} to be nil."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

  class AssertNotNilTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_nil`"
    setup do
      desc = @desc = "assert not nil empty fail desc"
      args = @args = [ nil, desc ]
      @test = Factory.test do
        assert_not_nil(1)     # pass
        assert_not_nil(*args) # fail
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
      exp = "#{@args[1]}\nExpected #{Assert::U.show(@args[0], @c)} to not be nil."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

end

