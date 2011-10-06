require 'assert'

class Assert::Context

  class ClassMethodsTest < Assert::Context
    desc "Assert context class"
    setup do
      @test = Factory.test
      @context_class = @test.context_class
    end
    teardown do
      TEST_ASSERT_SUITE.tests.clear
    end
    subject{ @context_class }

    should have_instance_methods :setup_once, :before_once, :startup
    should have_instance_methods :teardown_once, :after_once, :shutdown
    should have_instance_methods :setup, :before, :setups
    should have_instance_methods :teardown, :after, :teardowns
    should have_instance_methods :description, :desc, :describe, :subject
    should have_instance_methods :test, :test_eventually, :test_skip
    should have_instance_methods :should, :should_eventually, :should_skip
  end



  class SetupOnceTest < ClassMethodsTest
    desc "setup_once method"
    setup do
      setup_block = @setup_block = ::Proc.new{ something_once = true }
      @context_class = Factory.context_class do
        setup_once(&setup_block)
      end
      @setup_blocks = Assert.suite.send(:setups)
    end
    teardown do
      Assert.suite.send(:setups).reject!{|b| b == @setup_block }
    end
    subject{ @setup_blocks }

    should "add the block to the suite's collection of setup blocks" do
      assert_includes @setup_block, subject
    end

  end



  class TeardownOnceTest < ClassMethodsTest
    desc "teardown_once method"
    setup do
      teardown_block = @teardown_block = ::Proc.new{ something_once = true }
      @context_class = Factory.context_class do
        teardown_once(&teardown_block)
      end
      @teardown_blocks = Assert.suite.send(:teardowns)
    end
    teardown do
      Assert.suite.send(:teardowns).reject!{|b| b == @teardown_block }
    end
    subject{ @teardown_blocks }

    should "add the block to the suite's collection of teardown blocks" do
      assert_includes @teardown_block, subject
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
      assert_includes @setup_block, subject
    end

  end



  class SetupWithMethodNameTest < ClassMethodsTest
    desc "setup with method name"
    setup do
      method_name = @method_name = :setup_something_amazing
      @context_class = Factory.context_class do
        setup(method_name)
      end
      @setups = @context_class.send(:setups)
    end
    subject{ @setups }

    should "add the method name to the context setups" do
      assert_includes @method_name, subject
    end
  end


  class MultipleSetupsTest < ClassMethodsTest
    desc "a context class with multiple setups"
    setup do
      method_name = :setup_something_amazing
      klass = Class.new do
        attr_accessor :status

        define_method(method_name) do
          self.status += " with something amazing"
        end
      end
      @object = klass.new
      setup_block = @setup_block = ::Proc.new{ self.status = "the setup" }
      @parent_class = Factory.context_class do
        setup(&setup_block)
      end
      setup_block = @setup_block = ::Proc.new{ self.status += " has been run" }
      @context_class = Factory.context_class(@parent_class) do
        setup(&setup_block)
        setup(method_name)
      end
      @context_class.setup(@object)
      @expected = "the setup has been run with something amazing"
    end
    subject{ @object }

    should "run it's parent and it's own setup blocks in the correct order" do
      assert_equal @expected, subject.status
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
      assert_includes @teardown_block, subject
    end

  end



  class TeardownWithMethodNameTest < ClassMethodsTest
    desc "teardown with method name"
    setup do
      method_name = @method_name = "teardown_something_amazing"
      @context_class = Factory.context_class do
        teardown(method_name)
      end
      @teardowns = @context_class.send(:teardowns)
    end
    subject{ @teardowns }

    should "add the method name to the context teardowns" do
      assert_includes @method_name, subject
    end
  end



  class MultipleTeardownsTest < ClassMethodsTest
    desc "a context class with multiple teardowns"
    setup do
      method_name = :teardown_something_amazing
      klass = Class.new do
        attr_accessor :status

        define_method(method_name) do
          self.status += " with something amazing"
        end
      end
      @object = klass.new
      teardown_block = @teardown_block = ::Proc.new{ self.status += " has been run" }
      @parent_class = Factory.context_class do
        teardown(&teardown_block)
        teardown(method_name)
      end
      teardown_block = @teardown_block = ::Proc.new{ self.status = "the teardown" }
      @context_class = Factory.context_class(@parent_class) do
        teardown(&teardown_block)
      end
      @context_class.teardown(@object)
      @expected = "the teardown has been run with something amazing"
    end
    subject{ @object }

    should "run it's parent and it's own teardown blocks in the correct order" do
      assert_equal @expected, subject.status
    end

  end



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
        assert_includes text, subject
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



  class TestMethTest < ClassMethodsTest
    desc "test method"
    setup do
      @should_desc = "be true"
      @should_block = ::Proc.new{ assert(true) }
      @method_name = "test: #{@should_desc}"

      d, b = @should_desc, @should_block
      @context_class = Factory.context_class { test(d, &b) }
      @context = @context_class.new(Factory.test("something", Factory.context_info(@context_class)))
    end
    subject{ @context }

    should "define a test method named after the should desc" do
      assert_respond_to @method_name, subject
      assert_equal subject.instance_eval(&@should_block), subject.send(@method_name)
    end

  end

  class NoBlockTestMethTest < TestMethTest
    desc "called with no block"
    setup do
      d = @should_desc
      @context_class = Factory.context_class { test(d) }
      @context = @context_class.new(Factory.test("something", Factory.context_info(@context_class)))
    end
    subject{ @context }

    should "define a test method named after the should desc that raises a test skipped" do
      assert_raises(Assert::Result::TestSkipped) do
        subject.send(@method_name)
      end
    end

  end

  class TestEventuallyTest < TestMethTest
    desc "test_eventually method"
    setup do
      d, b = @should_desc, @should_block
      @context_class = Factory.context_class do
        test_eventually(d, &b)
      end
      @context = @context_class.new(Factory.test("something", Factory.context_info(@context_class)))
    end
    subject{ @context }

    should "define a test method named after the should desc that raises a test skipped" do
      assert_respond_to @method_name, subject
      assert_raises(Assert::Result::TestSkipped) do
        subject.send(@method_name)
      end
    end

  end



  class ShouldTest < ClassMethodsTest
    desc "'should' method"
    setup do
      @should_desc = "be true"
      @should_block = ::Proc.new{ assert(true) }
      @method_name = "test: should #{@should_desc}"

      d, b = @should_desc, @should_block
      @context_class = Factory.context_class { should(d, &b) }
      @context = @context_class.new(Factory.test("something", Factory.context_info(@context_class)))
    end
    subject{ @context }

    should "define a test method named after the should desc" do
      assert_respond_to @method_name, subject
      assert_equal subject.instance_eval(&@should_block), subject.send(@method_name)
    end

  end

  class NoBlockShouldTest < ShouldTest
    desc "called with no block"
    setup do
      d = @should_desc
      @context_class = Factory.context_class { should(d) }
      @context = @context_class.new(Factory.test("something", Factory.context_info(@context_class)))
    end
    subject{ @context }

    should "define a test method named after the should desc that raises a test skipped" do
      assert_raises(Assert::Result::TestSkipped) do
        subject.send(@method_name)
      end
    end

  end

  class ShouldEventuallyTest < ShouldTest
    desc "should_eventually method"
    setup do
      d, b = @should_desc, @should_block
      @context_class = Factory.context_class { should_eventually(d, &b) }
      @context = @context_class.new(Factory.test("something", Factory.context_info(@context_class)))
    end
    subject{ @context }

    should "define a test method named after the should desc that raises a test skipped" do
      assert_respond_to @method_name, subject
      assert_raises(Assert::Result::TestSkipped) do
        subject.send(@method_name)
      end
    end

  end

end
