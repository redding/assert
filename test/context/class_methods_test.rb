require 'assert'

class Assert::Context::ClassMethodsTest < Assert::Context
  desc "Assert context class"
  setup do
    @test = Factory.test
    @context_class = @test.context_class
  end
  subject{ @context_class }

  CLASS_METHODS = [
    :setup_once, :before_once, :teardown_once, :after_once,
    :setup, :before, :teardown, :after,
    :setups, :teardowns,
    :desc, :description,
    :subject,
    :should
  ]
  CLASS_METHODS.each do |class_method|
    should "respond to the class method ##{class_method}" do
      assert_respond_to subject, class_method
    end
  end

  teardown do
    TEST_ASSERT_SUITE.clear
  end



  class SetupOnceTest < ClassMethodsTest
    desc "setup_once method"
    setup do
      setup_block = @setup_block = ::Proc.new{ something_once = true }
      @context_class = Factory.context_class do
        setup_once(&setup_block)
      end
      @setup_blocks = Assert.suite.setup_blocks
    end
    subject{ @setup_blocks }

    should "add the block to the suite's collection of setup blocks" do
      assert_includes subject, @setup_block
    end

    teardown do
      Assert.suite.setup_blocks.reject!{|b| b == @setup_block }
    end

  end



  class TeardownOnceTest < ClassMethodsTest
    desc "teardown_once method"
    setup do
      teardown_block = @teardown_block = ::Proc.new{ something_once = true }
      @context_class = Factory.context_class do
        teardown_once(&teardown_block)
      end
      @teardown_blocks = Assert.suite.teardown_blocks
    end
    subject{ @teardown_blocks }

    should "add the block to the suite's collection of teardown blocks" do
      assert_includes subject, @teardown_block
    end

    teardown do
      Assert.suite.teardown_blocks.reject!{|b| b == @teardown_block }
    end

  end



  class SetupTest < ClassMethodsTest
    desc "setup method"
    setup do
      setup_block = @setup_block = ::Proc.new{ @something = true }
      @context_class = Factory.context_class do
        setup(&setup_block)
      end
      @setup_blocks = @context_class.send(:setups)
    end
    subject{ @setup_blocks }

    should "add the block to the context's collection of setup blocks" do
      assert_includes subject, @setup_block
    end

  end



  class TeardownTest < ClassMethodsTest
    desc "teardown method"
    setup do
      teardown_block = @teardown_block = ::Proc.new{ @something = false }
      @context_class = Factory.context_class do
        teardown(&teardown_block)
      end
      @teardown_blocks = @context_class.send(:teardowns)
    end
    subject{ @teardown_blocks }

    should "add the block to the context's collection of teardown blocks" do
      assert_includes subject, @teardown_block
    end

  end


  # TODO: give a dummy scope and verify exectution via contents and order
  # class AllSetupBlocksTest < ClassMethodsTest
  #   desc "all_setup_blocks method"
  #   setup do
  #     parent_block = @parent_block = ::Proc.new{ @parent_something = true }
  #     @parent_class = Factory.context_class do
  #       setup(&parent_block)
  #     end
  #     setup_block = @setup_block = ::Proc.new{ @something = true }
  #     @context_class = Factory.context_class(@parent_class) do
  #       setup(&setup_block)
  #     end
  #     @setup_blocks = @context_class.all_setup_blocks
  #   end
  #   subject{ @setup_blocks }

  #   should "return a collection containing both context's setup blocks" do
  #     assert_kind_of Array, subject
  #     assert_includes subject, @parent_block
  #     assert_includes subject, @setup_block
  #   end

  # end



  # TODO: give a dummy scope and verify exectution via contents and order
  # class AllTeardownBlocksTest < ClassMethodsTest
  #   desc "all_teardown_blocks method"
  #   setup do
  #     parent_block = @parent_block = ::Proc.new{ @parent_something = false }
  #     @parent_class = Factory.context_class do
  #       teardown(&parent_block)
  #     end
  #     teardown_block = @teardown_block = ::Proc.new{ @something = false }
  #     @context_class = Factory.context_class(@parent_class) do
  #       teardown(&teardown_block)
  #     end
  #     @teardown_blocks = @context_class.all_teardown_blocks
  #   end
  #   subject{ @teardown_blocks }

  #   should "return a collection containing both context's setup blocks" do
  #     assert_kind_of Array, subject
  #     assert_includes subject, @parent_block
  #     assert_includes subject, @teardown_block
  #   end

  # end



  class DescTest < ClassMethodsTest
    desc "desc method with an arg"
    setup do
      descs = @descs = [ "something amazing", "it really is" ]
      @context_class = Factory.context_class do
        descs.each do |text|
          desc text
        end
      end
    end
    subject{ @context_class.send(:descriptions) }

    should "return a collection containing any descriptions defined on the class" do
      assert_kind_of Array, subject
      @descs.each do |text|
        assert_includes subject, text
      end
    end

  end



  class FullDescriptionTest < ClassMethodsTest
    desc "description method without an arg"
    setup do
      parent_text = @parent_desc = "parent description"
      @parent_class = Factory.context_class do
        desc parent_text
      end
      text = @desc = "and the description for this context"
      @context_class = Factory.context_class(@parent_class) do
        desc text
      end
      @full_description = @context_class.description
    end
    subject{ @full_description }

    should "return a string of all the inherited descriptions" do
      assert_kind_of String, subject
      assert_match @parent_desc, subject
      assert_match @desc, subject
    end

  end



  class SubjectFromLocalTest < ClassMethodsTest
    desc "subject method using local context"
    setup do
      subject_block = @subject_block = ::Proc.new{ @something }
      @context_class = Factory.context_class do
        subject(&subject_block)
      end
    end
    subject{ @subject_block }

    should "set the subject block on the context class" do
      assert_equal @context_class.subject, subject
    end

  end



  class SubjectFromParentTest < ClassMethodsTest
    desc "subject method using parent context"
    setup do
      parent_block = @parent_block = ::Proc.new{ @something }
      @parent_class = Factory.context_class do
        subject(&parent_block)
      end
      @context_class = Factory.context_class(@parent_class)
    end
    subject{ @parent_block }

    should "default to it's parents subject block" do
      assert_equal subject, @context_class.subject
    end
  end



  class ShouldTest < ClassMethodsTest
    desc "should method"
    setup do
      should_desc = "be true"
      should_block = @should_block = ::Proc.new{ assert(true) }
      @context_class = Factory.context_class do
        should(should_desc, &should_block)
      end
      @method_name = "test: should #{should_desc}"
      @context = @context_class.new(Factory.test("something", @context_class))
    end
    subject{ @context }

    should "define a test method named after the should desc" do
      assert_respond_to subject, @method_name
      assert_equal subject.instance_eval(&@should_block), subject.send(@method_name)
    end

  end



  class ShouldEventuallyTest < ClassMethodsTest
    desc "should_eventually method"
    setup do
      should_desc = @should_desc = "be true"
      should_block = @should_block = ::Proc.new{ assert(true) }
      @context_class = Factory.context_class do
        should_eventually(should_desc, &should_block)
      end
      @method_name = "test: should #{@should_desc}"
      @context = @context_class.new(Factory.test("something", @context_class))
    end
    subject{ @context }

    should "define a test method named after the should desc that raises a test skipped" do
      assert_respond_to subject, @method_name
      assert_raises(Assert::Result::TestSkipped) do
        subject.send(@method_name)
      end
    end

  end

end
