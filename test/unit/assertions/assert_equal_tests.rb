require 'assert'
require 'assert/assertions'

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
      exp = "#{@args[2]}\nExpected #{@args[0].inspect}, not #{@args[1].inspect}."
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
            "#{@args[1].inspect} not expected to equal #{@args[0].inspect}."
      assert_equal exp, subject.fail_results.first.message
    end

  end

end
