require 'assert'
require 'assert/assertions'

require 'assert/utils'

module Assert::Assertions

  class AssertSameTests < Assert::Context
    desc "`assert_same`"
    setup do
      klass = Class.new; object = klass.new
      desc = @desc = "assert same fail desc"
      args = @args = [ object, klass.new, desc ]
      @test = Factory.test do
        assert_same(object, object) # pass
        assert_same(*args)          # fail
      end
      @c = @test.config
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
            "Expected #{Assert::U.show(@args[1], @c)}"\
            " (#<#{@args[1].class}:#{'0x0%x' % (@args[1].object_id << 1)}>)"\
            " to be the same as #{Assert::U.show(@args[0], @c)}"\
            " (#<#{@args[0].class}:#{'0x0%x' % (@args[0].object_id << 1)}>)."
      assert_equal exp, subject.fail_results.first.message
    end

  end

  class AssertNotSameTests < Assert::Context
    desc "`assert_not_same`"
    setup do
      klass = Class.new; object = klass.new
      desc = @desc = "assert not same fail desc"
      args = @args = [ object, object, desc ]
      @test = Factory.test do
        assert_not_same(*args)             # fail
        assert_not_same(object, klass.new) # pass
      end
      @c = @test.config
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
            "Expected #{Assert::U.show(@args[1], @c)}"\
            " (#<#{@args[1].class}:#{'0x0%x' % (@args[1].object_id << 1)}>)"\
            " to not be the same as #{Assert::U.show(@args[0], @c)}"\
            " (#<#{@args[0].class}:#{'0x0%x' % (@args[0].object_id << 1)}>)."
      assert_equal exp, subject.fail_results.first.message
    end

  end

  class DiffTests < Assert::Context
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

  class AssertSameDiffTests < DiffTests
    desc "`assert_same`"
    setup do
      exp_obj, act_obj = @exp_obj, @act_obj
      @test = Factory.test(@c) do
        assert_same(exp_obj, act_obj)
      end
      @test.run
    end
    subject{ @test }

    should "include diff output in the fail messages" do
      exp = "Expected #<#{@act_obj.class}:#{'0x0%x' % (@act_obj.object_id << 1)}>"\
            " to be the same as"\
            " #<#{@exp_obj.class}:#{'0x0%x' % (@exp_obj.object_id << 1)}>"\
            ", diff:\n"\
            "#{Assert::U.syscmd_diff_proc.call(@exp_obj_show, @act_obj_show)}"
      assert_equal exp, subject.fail_results.first.message
    end

  end

  class AssertNotSameDiffTests < DiffTests
    desc "`assert_not_same`"
    setup do
      @exp_obj = @act_obj
      @exp_obj_show = @act_obj_show

      exp_obj, act_obj = @exp_obj, @act_obj
      @test = Factory.test(@c) do
        assert_not_same(exp_obj, exp_obj)
      end
      @test.run
    end
    subject{ @test }

    should "include diff output in the fail messages" do
      exp = "Expected #<#{@act_obj.class}:#{'0x0%x' % (@act_obj.object_id << 1)}>"\
            " to not be the same as"\
            " #<#{@exp_obj.class}:#{'0x0%x' % (@exp_obj.object_id << 1)}>"\
            ", diff:\n"\
            "#{Assert::U.syscmd_diff_proc.call(@exp_obj_show, @act_obj_show)}"
      assert_equal exp, subject.fail_results.first.message
    end

  end

end

