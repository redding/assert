require 'assert'
require 'assert/assertions'

require 'assert/utils'

module Assert::Assertions

  class AssertIncludesTests < Assert::Context
    desc "the assert_includes helper"
    setup do
      desc = @desc = "assert includes fail desc"
      args = @args = [ 2, [ 1 ], desc ]
      @test = Factory.test do
        assert_includes(1, [ 1 ]) # pass
        assert_includes(*args)    # fail
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
            "Expected #{Assert::U.show(@args[1])} to include #{Assert::U.show(@args[0])}."
      assert_equal exp, subject.fail_results.first.message
    end

  end

  class AssertNotIncluded < Assert::Context
    desc "the assert_not_included helper"
    setup do
      desc = @desc = "assert not included fail desc"
      args = @args = [ 1, [ 1 ], desc ]
      @test = Factory.test do
        assert_not_included(2, [ 1 ]) # pass
        assert_not_included(*args)    # fail
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
            "Expected #{Assert::U.show(@args[1])} to not include #{Assert::U.show(@args[0])}."
      assert_equal exp, subject.fail_results.first.message
    end

  end

end

