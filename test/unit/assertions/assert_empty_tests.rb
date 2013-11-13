require 'assert'
require 'assert/assertions'

require 'assert/utils'

module Assert::Assertions

  class AssertEmptyTests < Assert::Context
    desc "the assert_empty helper"
    setup do
      desc = @desc = "assert empty fail desc"
      args = @args = [ [ 1 ], desc ]
      @test = Factory.test do
        assert_empty([])    # pass
        assert_empty(*args) # fail
      end
      @test.run
    end
    subject{ @test }

    should "produce results as expected" do
      assert_equal 2, subject.result_count
      assert_equal 1, subject.result_count(:pass)
      assert_equal 1, subject.result_count(:fail)
    end

    should "have a fail message with custom and generic explanations" do
      exp = "#{@args[1]}\nExpected #{Assert::U.pp(@args[0])} to be empty."
      assert_equal exp, subject.fail_results.first.message
    end

  end

  class AssertNotEmptyTests < Assert::Context
    desc "the assert_not_empty helper"
    setup do
      desc = @desc = "assert not empty fail desc"
      args = @args = [ [], desc ]
      @test = Factory.test do
        assert_not_empty([ 1 ]) # pass
        assert_not_empty(*args) # fail
      end
      @test.run
    end
    subject{ @test }

    should "produce results as expected" do
      assert_equal 2, subject.result_count
      assert_equal 1, subject.result_count(:pass)
      assert_equal 1, subject.result_count(:fail)
    end

    should "have a fail message with custom and generic explanations" do
      exp = "#{@args[1]}\nExpected #{Assert::U.pp(@args[0])} to not be empty."
      assert_equal exp, subject.fail_results.first.message
    end

  end

end
