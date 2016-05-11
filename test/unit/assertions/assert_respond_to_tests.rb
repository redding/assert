require 'assert'
require 'assert/assertions'

require 'assert/utils'

module Assert::Assertions

  class AssertRespondToTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_respond_to`"
    setup do
      desc = @desc = "assert respond to fail desc"
      args = @args = [ :abs, "1", desc ]
      @test = Factory.test do
        assert_respond_to(:abs, 1) # pass
        assert_respond_to(*args)   # fail
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
            "Expected #{Assert::U.show(@args[1], @c)} (#{@args[1].class})"\
            " to respond to `#{@args[0]}`."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

  class AssertNotRespondToTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_respond_to`"
    setup do
      desc = @desc = "assert not respond to fail desc"
      args = @args = [ :abs, 1, desc ]
      @test = Factory.test do
        assert_not_respond_to(*args)     # fail
        assert_not_respond_to(:abs, "1") # pass
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
            "Expected #{Assert::U.show(@args[1], @c)} (#{@args[1].class})"\
            " to not respond to `#{@args[0]}`."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

end

