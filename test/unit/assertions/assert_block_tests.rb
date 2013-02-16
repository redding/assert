require 'assert'
require 'assert/assertions'

module Assert::Assertions

  class AssertBlockTests < Assert::Context
    desc "the `assert_block` helper"
    setup do
      desc = @desc = "assert block fail desc"
      @test = Factory.test do
        assert_block{ true }        # pass
        assert_block(desc){ false } # fail
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
      exp = "#{@desc}\nExpected block to return a true value."
      assert_equal exp, subject.fail_results.first.message
    end

  end

  class AssertNotBlockTests < Assert::Context
    desc "the assert_not_block helper"
    setup do
      desc = @desc = "assert not block fail desc"
      @test = Factory.test do
        assert_not_block(desc){ true } # fail
        assert_not_block{ false }      # pass
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
      exp = "#{@desc}\nExpected block to return a false value."
      assert_equal exp, subject.fail_results.first.message
    end

  end

end

