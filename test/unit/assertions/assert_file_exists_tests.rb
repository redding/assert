require "assert"
require "assert/assertions"

require "assert/utils"

module Assert::Assertions

  class AssertFileExistsTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_file_exists`"
    setup do
      desc = @desc = "assert file exists empty fail desc"
      args = @args = [ "/a/path/to/some/file/that/no/exists", desc ]
      @test = Factory.test do
        assert_file_exists(__FILE__) # pass
        assert_file_exists(*args)    # fail
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
      exp = "#{@args[1]}\nExpected #{Assert::U.show(@args[0], @c)} to exist."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

  class AssertNotFileExistsTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_file_exists`"
    setup do
      desc = @desc = "assert not file exists empty fail desc"
      args = @args = [ __FILE__, desc ]
      @test = Factory.test do
        assert_not_file_exists("/a/path/to/some/file/that/no/exists") # pass
        assert_not_file_exists(*args) # fail
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
      exp = "#{@args[1]}\nExpected #{Assert::U.show(@args[0], @c)} to not exist."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

end

