require 'assert'
require 'assert/assertions'

require 'assert/utils'

module Assert::Assertions

  class AssertEqualUnitTests < Assert::Context
    setup do
      @orig_pp_objects = Assert.config.pp_objects
      Assert.config.pp_objects(false)
    end
    teardown do
      Assert.config.pp_objects(@orig_pp_objects)
    end

  end

  class AssertEqualTests < AssertEqualUnitTests
    desc "`assert_equal`"
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

  class AssertNotEqualTests < AssertEqualUnitTests
    desc "`assert_not_equal`"
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

  class DiffTests < AssertEqualUnitTests
    desc "with objects that should use diff when showing"
    setup do
      @exp_obj = "I'm a\nstring"
      @act_obj = "I am a \nstring"

      @exp_obj_show = Assert::U.show_for_diff(@exp_obj)
      @act_obj_show = Assert::U.show_for_diff(@act_obj)

      @orig_use_diff_proc = Assert.config.use_diff_proc
      @orig_run_diff_proc = Assert.config.run_diff_proc

      Assert.config.use_diff_proc(Assert::U.default_use_diff_proc)
      Assert.config.run_diff_proc(Assert::U.syscmd_diff_proc)
    end
    teardown do
      Assert.config.use_diff_proc(@orig_use_diff_proc)
      Assert.config.run_diff_proc(@orig_run_diff_proc)
    end

  end

  class AssertEqualDiffTests < DiffTests
    desc "`assert_equal`"
    setup do
      exp_obj, act_obj = @exp_obj, @act_obj
      @test = Factory.test do
        assert_equal(exp_obj, act_obj)
      end
      @test.run
    end
    subject{ @test }

    should "include diff output in the fail messages" do
      exp = "Expected does not equal actual, diff:\n"\
            "#{Assert::U.syscmd_diff_proc.call(@exp_obj_show, @act_obj_show)}"
      assert_equal exp, subject.fail_results.first.message
    end

  end

  class AssertNotEqualDiffTests < DiffTests
    desc "`assert_not_equal`"
    setup do
      exp_obj, act_obj = @exp_obj, @act_obj
      @test = Factory.test do
        assert_not_equal(exp_obj, exp_obj)
      end
      @test.run
    end
    subject{ @test }

    should "include diff output in the fail messages" do
      exp = "Expected equals actual, diff:\n"\
            "#{Assert::U.syscmd_diff_proc.call(@exp_obj_show, @exp_obj_show)}"
      assert_equal exp, subject.fail_results.first.message
    end

  end

end
