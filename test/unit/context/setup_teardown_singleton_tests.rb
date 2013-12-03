require 'assert'
require 'assert/context'

class Assert::Context

  class SetupTeardownSingletonUnitTests < Assert::Context
    desc "setup and teardown"
    setup do
      @context_class = Factory.context_class
    end
    subject{ @context_class }

  end

  class SetupTeardownOnceMethodsTests < SetupTeardownSingletonUnitTests
    desc "once methods"
    setup do
      block = @block = ::Proc.new{ something_once = true }
      @context_class = Factory.context_class do
        setup_once(&block)
        teardown_once(&block)
      end
    end
    teardown do
      Assert.suite.send(:setups).reject!{ |b| b == @block }
    end

    should "add the block to the suite" do
      assert_includes @block, Assert.suite.send(:setups)
      assert_includes @block, Assert.suite.send(:teardowns)
    end

  end

  class SetupTeardownMethodsTests < SetupTeardownSingletonUnitTests
    desc "methods"
    setup do
      block = @block = ::Proc.new{ something = true }
      @context_class = Factory.context_class do
        setup(&block)
        teardown(&block)
      end
    end

    should "add the block to the context" do
      assert_includes @block, subject.send(:setups)
      assert_includes @block, subject.send(:teardowns)
    end

  end

  class SetupTeardownWithMethodNameTests < SetupTeardownSingletonUnitTests
    desc "methods given a method name"
    setup do
      method_name = @method_name = :something_amazing
      @context_class = Factory.context_class do
        setup(method_name)
        teardown(method_name)
      end
    end

    should "add the method name to the context" do
      assert_includes @method_name, subject.send(:setups)
      assert_includes @method_name, subject.send(:teardowns)
    end

  end

  class SetupTeardownMultipleTests < SetupTeardownSingletonUnitTests
    desc "with multiple calls"
    setup do
      parent_setup_block    = ::Proc.new{ self.setup_status    =  "the setup"    }
      parent_teardown_block = ::Proc.new{ self.teardown_status += "the teardown" }
      @parent_class = Factory.context_class do
        setup(&parent_setup_block)
        teardown(&parent_teardown_block)
      end

      context_setup_block    = ::Proc.new{ self.setup_status    += " has been run" }
      context_teardown_block = ::Proc.new{ self.teardown_status += "has been run " }
      @context_class = Factory.context_class(@parent_class) do
        setup(&context_setup_block)
        setup(:setup_something)
        teardown(:teardown_something)
        teardown(&context_teardown_block)
      end

      @test_status_class = Class.new do
        attr_accessor :setup_status, :teardown_status
        define_method(:setup_something) do
          self.setup_status += " with something"
        end
        define_method(:teardown_something) do
          self.teardown_status = "with something "
        end
      end
    end

    should "run it's parent and it's own blocks in the correct order" do
      subject.setup(obj = @test_status_class.new)
      assert_equal "the setup has been run with something", obj.setup_status

      subject.teardown(obj = @test_status_class.new)
      assert_equal "with something has been run the teardown", obj.teardown_status
    end

  end

end
