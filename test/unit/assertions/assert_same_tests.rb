require 'assert'
require 'assert/assertions'

require 'assert/utils'

module Assert::Assertions

  class AssertSameTest < Assert::Context
    desc "the assert_same helper"
    setup do
      klass = Class.new; object = klass.new
      desc = @desc = "assert same fail desc"
      args = @args = [ object, klass.new, desc ]
      @test = Factory.test do
        assert_same(object, object) # pass
        assert_same(*args)          # fail
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
            "Expected #{Assert::U.pp(@args[1])} (#{@args[1].object_id})"\
            " to be the same as #{Assert::U.pp(@args[0])} (#{@args[0].object_id})."
      assert_equal exp, subject.fail_results.first.message
    end

  end

  class AssertNotSameTests < Assert::Context
    desc "the assert_not_same helper"
    setup do
      klass = Class.new; object = klass.new
      desc = @desc = "assert not same fail desc"
      args = @args = [ object, object, desc ]
      @test = Factory.test do
        assert_not_same(*args)             # fail
        assert_not_same(object, klass.new) # pass
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
            "#{Assert::U.pp(@args[1])} (#{@args[1].object_id}) not expected"\
            " to be the same as #{Assert::U.pp(@args[0])} (#{@args[0].object_id})."
      assert_equal exp, subject.fail_results.first.message
    end

  end

end

