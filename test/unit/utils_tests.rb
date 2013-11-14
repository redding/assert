require 'assert'
require 'assert/utils'

module Assert::Utils

  class UnitTests < Assert::Context
    desc "Assert::Utils"
    setup do
      @objs = [ 1, 'hi there', Hash.new, [:a, :b]]
    end
    subject{ Assert::Utils }

    should have_imeths :show, :stdlib_pp_proc

    should "build a pp proc that uses stdlib `PP.pp` to pretty print objects" do
      exp_obj_pps = @objs.map{ |o| "\n#{PP.pp(o, '', 79).strip}\n" }
      act_obj_pps = @objs.map{ |o| subject.stdlib_pp_proc.call(o) }
      assert_equal exp_obj_pps, act_obj_pps

      cust_width = 1
      exp_obj_pps = @objs.map{ |o| "\n#{PP.pp(o, '', cust_width).strip}\n" }
      act_obj_pps = @objs.map{ |o| subject.stdlib_pp_proc(cust_width).call(o) }
      assert_equal exp_obj_pps, act_obj_pps
    end

  end

  class ShowTests < UnitTests
    desc "`show`"
    setup do
      @orig_pp_objs = Assert.config.pp_objects
      @orig_pp_proc = Assert.config.pp_proc
      @new_pp_proc  = Proc.new{ |input| 'herp derp' }
    end
    teardown do
      Assert.config.pp_proc(@orig_pp_proc)
      Assert.config.pp_objects(@orig_pp_objs)
    end

    should "use `inspect` to show objs when `pp_objects` setting is false" do
      Assert.config.pp_objects(false)

      @objs.each do |obj|
        assert_equal obj.inspect, subject.show(obj)
      end
    end

    should "use `pp_proc` to show objs when `pp_objects` setting is true" do
      Assert.config.pp_objects(true)
      Assert.config.pp_proc(@new_pp_proc)

      @objs.each do |obj|
        assert_equal @new_pp_proc.call(obj), subject.show(obj)
      end
    end

  end

end
