require 'assert'
require 'assert/assertions'

require 'assert/utils'

module Assert::Assertions

  class AssertEqualTests < Assert::Context
    desc "the assert_equal helper"
    setup do
      desc = @desc = "assert equal fail desc"
      args = @args = [ '1', '2', desc ]
      @test = Factory.test do
        assert_equal(1, 1)   # pass
        assert_equal(*args)  # fail
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
      exp = "#{@args[2]}\nExpected #{Assert::U.show(@args[0])}, not #{Assert::U.show(@args[1])}."
      assert_equal exp, subject.fail_results.first.message
    end

  end

  class AssertNotEqualTests < Assert::Context
    desc "the assert_not_equal helper"
    setup do
      desc = @desc = "assert not equal fail desc"
      args = @args = [ '1', '1', desc ]
      @test = Factory.test do
        assert_not_equal(*args)  # fail
        assert_not_equal(1, 2)   # pass
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
      exp = "#{@args[2]}\n"\
            "#{Assert::U.show(@args[1])} not expected to equal #{Assert::U.show(@args[0])}."
      assert_equal exp, subject.fail_results.first.message
    end

  end

end
