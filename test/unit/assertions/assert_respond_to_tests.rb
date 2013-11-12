require 'assert'
require 'assert/assertions'

require 'assert/utils'

module Assert::Assertions

  class AssertRespondToTest < Assert::Context
    desc "the assert_respond_to helper"
    setup do
      desc = @desc = "assert respond to fail desc"
      args = @args = [ :abs, "1", desc ]
      @test = Factory.test do
        assert_respond_to(:abs, 1) # pass
        assert_respond_to(*args)   # fail
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
            "Expected #{Assert::U.pp(@args[1])} (#{@args[1].class})"\
            " to respond to `#{@args[0]}`."
      assert_equal exp, subject.fail_results.first.message
    end

  end

  class AssertNotRespondToTests < Assert::Context
    desc "the assert_not_respond_to helper"
    setup do
      desc = @desc = "assert not respond to fail desc"
      args = @args = [ :abs, 1, desc ]
      @test = Factory.test do
        assert_not_respond_to(*args)     # fail
        assert_not_respond_to(:abs, "1") # pass
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
            "#{Assert::U.pp(@args[1])} (#{@args[1].class})"\
            " not expected to respond to `#{@args[0]}`."
      assert_equal exp, subject.fail_results.first.message
    end

  end

end

