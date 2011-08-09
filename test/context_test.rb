require 'test_belt'
require 'assert/context'

require 'assert/test'

class Assert::Context



  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "a context"
    subject do
      context_klass = Assert::Context
      test = Assert::Test.new("something", ::Proc.new {}, context_klass)
      context_klass.new(test)
    end

    should have_instance_methods :assert, :refute

    should "make assertions" do
      assert_nothing_raised do
        subject.assert(1==1)
      end
    end

    should "make refutations" do
      assert_nothing_raised do
        subject.refute(1==0)
      end
    end

  end



  class SkipTest < BasicTest

    should have_instance_methods :skip

    should "skip a test with a method call" do
      assert_raises Assert::Result::Skip do
        subject.skip
      end
    end

  end



  class PassTest < BasicTest

    should have_instance_methods :pass

    should "pass a test with a method call" do
      assert_raises Assert::Result::Pass do
        subject.pass
      end
    end

    should "pass asserts that are not false or nil" do
      assert_kind_of Assert::Result::Pass, subject.assert(34)
    end

    should "pass refutes that are false" do
      assert_kind_of Assert::Result::Pass, subject.refute(false)
    end

    should "pass refutes that are nil" do
      assert_kind_of Assert::Result::Pass, subject.refute(nil)
    end


  end



  class FailTest < BasicTest

    should have_instance_methods :fail, :flunk

    should "fail tests with a method call" do
      assert_raises Assert::Result::Fail do
        subject.fail
      end
    end

    should "fail tests with a method call and custom message" do
      begin
        subject.fail("your test failed")
      rescue Assert::Result::Fail => err
        assert_equal "your test failed", err.message
      end
    end

    should "flunk tests with a method call" do
      assert_raises Assert::Result::Fail do
        subject.flunk
      end
    end

    should "flunk tests with a method call and custom message" do
      begin
        subject.flunk("your assertion flunked")
      rescue Assert::Result::Fail => err
        assert_equal "your assertion flunked", err.message
      end
    end

    should "fail asserts that are false" do
      assert_kind_of Assert::Result::Fail, subject.assert(false)
    end

    should "fail asserts that are nil" do
      assert_kind_of Assert::Result::Fail, subject.assert(nil)
    end

    should "fail refutes that are not false or nil" do
      assert_kind_of Assert::Result::Fail, subject.refute(34)
    end

  end


  class SetupAndTeardownTest < BasicTest

    subject{ Assert::Context.new }

    should have_class_methods :setup, :teardown, :_assert_setups, :_assert_teardowns
    should have_class_methods :before, :after

    should "add the setup block to the context's collection of setup blocks" do
      setup_block = lambda{ @something = true }
      subject.class.setup(&setup_block)
      assert(subject.class._assert_setups.include?(setup_block))
    end

    should "add the teardown block to the context's collection of teardown blocks" do
      teardown_block = lambda{ @something = false }
      subject.class.teardown(&teardown_block)
      assert(subject.class._assert_teardowns.include?(teardown_block))
    end

  end



  class NestedSetupTest < BasicTest
    
    setup do
      @base_block = lambda{ @nested_something = true }
      Assert::Context.setup(&@base_block)
      class NestedSetupTestContext < Assert::Context
        setup{ @not_nested = true }
      end
    end

    subject{ NestedSetupTestContext }
    
    should "return the parent's setup block in the context's setup blocks" do
      assert(subject._assert_setups.include?(@base_block))
    end
    should "have the parent's setup block as the first in the collection" do
      assert(subject._assert_setups.size > 1) # make sure it's not the only setup block
      assert_equal(@base_block, subject._assert_setups.first)
    end

    teardown do
      Assert.suite.delete(NestedSetupTestContext)
    end

  end
  
  
  
  class NestedTeardownTest < BasicTest
    
    setup do
      @base_block = lambda{ @nested_something = true }
      Assert::Context.teardown(&@base_block)
      class NestedTeardownTestContext < Assert::Context
        teardown{ @not_nested = true }
      end
    end

    subject{ NestedTeardownTestContext }
    
    should "return the parent's teardown block in the context's teardown blocks" do
      assert(subject._assert_teardowns.include?(@base_block))
    end
    should "have the parent's teardown block as the last in the collection" do
      assert(subject._assert_teardowns.size > 1) # make sure it's not the only setup block
      assert_equal(@base_block, subject._assert_teardowns.last)
    end
    
    teardown do
      Assert.suite.delete(NestedTeardownTestContext)
    end

  end



  class AssertionsTest < BasicTest

    should have_instance_methods :assert_block
    should have_instance_methods :assert_raises, :assert_raise
    should have_instance_methods :assert_nothing_raised
    should have_instance_methods :assert_kind_of, :assert_instance_of
    should have_instance_methods :assert_respond_to
    should have_instance_methods :assert_same, :assert_equal, :assert_match

    should have_instance_methods :refute_block
    should have_instance_methods :refute_raises, :refute_raise
    should have_instance_methods :refute_nothing_raised
    should have_instance_methods :refute_kind_of, :refute_instance_of
    should have_instance_methods :refute_respond_to
    should have_instance_methods :refute_same, :refute_equal, :refute_match

  end



end
