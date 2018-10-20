require "assert"
require "assert/assertions"

require "assert/utils"

module Assert::Assertions

  class AssertEqualTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_equal`"
    setup do
      desc = @desc = "assert equal fail desc"
      a = @a = [ "1", "2", desc ]
      @test = Factory.test do
        assert_equal(1, 1) # pass
        assert_equal(*a)   # fail
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
      exp = "#{@a[2]}\nExpected #{Assert::U.show(@a[1], @c)}"\
            " to be equal to #{Assert::U.show(@a[0], @c)}."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

  class AssertNotEqualTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_equal`"
    setup do
      desc = @desc = "assert not equal fail desc"
      a = @a = [ "1", "1", desc ]
      @test = Factory.test do
        assert_not_equal(*a)   # fail
        assert_not_equal(1, 2) # pass
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
      exp = "#{@a[2]}\nExpected #{Assert::U.show(@a[1], @c)}"\
            " to not be equal to #{Assert::U.show(@a[0], @c)}."
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

  class EqualOrderTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "with objects that define custom equality operators"
    setup do
      is_class = Class.new do
        def ==(other); true; end
      end
      @is = is_class.new

      is_not_class = Class.new do
        def ==(other); false; end
      end
      @is_not = is_not_class.new
    end

    should "use the equality operator of the exp value" do
      assert_equal @is, @is_not
      assert_not_equal @is_not, @is
    end

  end

  class DiffTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "with objects that should use diff when showing"
    setup do
      @exp_obj = "I'm a\nstring"
      @act_obj = "I am a \nstring"

      @c = Factory.modes_off_config
      @c.use_diff_proc(Assert::U.default_use_diff_proc)
      @c.run_diff_proc(Assert::U.syscmd_diff_proc)

      @exp_obj_show = Assert::U.show_for_diff(@exp_obj, @c)
      @act_obj_show = Assert::U.show_for_diff(@act_obj, @c)
    end

  end

  class AssertEqualDiffTests < DiffTests
    desc "`assert_equal`"
    setup do
      exp_obj, act_obj = @exp_obj, @act_obj
      @test = Factory.test(@c) do
        assert_equal(exp_obj, act_obj)
      end
      @test.run(&test_run_callback)
    end
    subject{ @test }

    should "include diff output in the fail messages" do
      exp = "Expected does not equal actual, diff:\n"\
            "#{Assert::U.syscmd_diff_proc.call(@exp_obj_show, @act_obj_show)}"
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

  class AssertNotEqualDiffTests < DiffTests
    desc "`assert_not_equal`"
    setup do
      exp_obj, act_obj = @exp_obj, @act_obj
      @test = Factory.test(@c) do
        assert_not_equal(exp_obj, exp_obj)
      end
      @test.run(&test_run_callback)
    end
    subject{ @test }

    should "include diff output in the fail messages" do
      exp = "Expected equals actual, diff:\n"\
            "#{Assert::U.syscmd_diff_proc.call(@exp_obj_show, @exp_obj_show)}"
      assert_equal exp, test_run_results(:fail).first.message
    end

  end

end
