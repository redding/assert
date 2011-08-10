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

    should have_instance_methods :assert, :assert_not, :refute
  end



  class SkipTest < BasicTest

    should have_instance_methods :skip

    should "skip a test with a method call" do
      assert_raises Assert::Result::TestSkipped do
        subject.skip
      end
    end
    
    should "store a custom message passed to the method" do
      skip_msg = "custom skip message yo"
      begin
        subject.skip(skip_msg)
      rescue Assert::Result::TestSkipped => exception
      end
      result = Assert::Result::Skip.new("something", exception)
      assert_equal(skip_msg, result.message)
    end

  end



  class IgnoreTest < BasicTest

    should have_instance_method :ignore

    should "ignore a test with a method call" do
      assert_kind_of Assert::Result::Ignore, subject.ignore
    end
    
    should "add a custom message to the result when provided" do
      ignore_msg = "custom ignore message yo"
      result = subject.ignore(ignore_msg)
      assert_equal(ignore_msg, result.message)
    end

  end



  class PassTest < BasicTest

    should have_instance_methods :pass

    should "pass a test with a method call" do
      assert_kind_of Assert::Result::Pass, subject.pass
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
    
    should "add a custom message to the result when provided" do
      pass_msg = "custom pass message yo"
      result = subject.pass(pass_msg)
      assert_equal(pass_msg, result.message)
    end

  end



  class FailTest < BasicTest

    should have_instance_methods :fail, :flunk

    should "fail tests with a method call" do
      assert_kind_of Assert::Result::Fail, subject.fail
    end

    should "flunk tests with a method call" do
      assert_kind_of Assert::Result::Fail, subject.flunk
    end

    should "fail tests with a method call and custom message" do
      assert_equal "your test failed", subject.fail("your test failed").message
    end

    should "flunk tests with a method call and custom message" do
      assert_equal "your test flunked", subject.flunk("your test flunked").message
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



  class ContextDescTest < BasicTest

    setup do
      @parent_description = "assert context description"
      Assert::Context.desc(@parent_description)
      description = @description = "random context class description"
      @context_class = Class.new(Assert::Context) do
        desc description
      end
    end

    subject{ @context_class.new }

    should have_class_methods :desc, :_assert_descs

    should "return the description with it's parent's descriptions" do
      descriptions = subject.class._assert_descs
      assert(descriptions.include?(@parent_description))
      assert(descriptions.include?(@description))
    end

    should "return the descriptions in the correct order" do
      descriptions = subject.class._assert_descs
      assert_equal(@parent_description, descriptions.first)
      assert_equal(@description, descriptions.last)
    end

    teardown do
      Assert::Context.instance_variable_set("@_assert_desc", nil)
    end

  end



  class SubjectTest < BasicTest

    setup do
      subject = @subject = "SUBJECT!"
      subject_block = @subject_block = lambda{ subject }
      @context_class = Class.new(Assert::Context) do
        subject(&subject_block)
      end
    end

    subject{ @context_class.new }

    should have_class_methods :subject, :_assert_subject

    should have_instance_methods :subject

    should "store the subject block on the class" do
      assert_equal(@subject_block, subject.class._assert_subject)
    end

    should "return the subject defined when called on the instance" do
      assert_equal(@subject, subject.subject)
    end

  end

end
