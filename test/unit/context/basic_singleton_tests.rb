require 'assert'
require 'assert/context'

class Assert::Context

  # `ContextSingletonTests` defined in `test/helper.rb`
  class BasicSingletonTests < ContextSingletonTests
    should have_instance_methods :setup_once, :before_once, :startup
    should have_instance_methods :teardown_once, :after_once, :shutdown
    should have_instance_methods :setup, :before, :setups
    should have_instance_methods :teardown, :after, :teardowns
    should have_instance_methods :description, :desc, :describe, :subject
    should have_instance_methods :test, :test_eventually, :test_skip
    should have_instance_methods :should, :should_eventually, :should_skip

  end

  class DescriptionsTests < BasicSingletonTests
    desc "`descriptions` method"
    setup do
      descs = @descs = [ "something amazing", "it really is" ]
      @context_class = Factory.context_class do
        descs.each{ |text| desc text }
      end
    end

    should "return a collection containing any descriptions defined on the class" do
      context_descs = subject.send :descriptions
      assert_equal @descs, context_descs
    end

  end

  class DescriptionTests < BasicSingletonTests
    desc "`description` method"
    setup do
      parent_text = @parent_desc = "parent description"
      @parent_class = Factory.context_class do
        desc parent_text
      end
      text = @desc = "and the description for this context"
      @context_class = Factory.context_class(@parent_class) do
        desc text
      end
    end

    should "return a string of all the inherited descriptions" do
      exp_desc = "parent description and the description for this context"
      assert_equal exp_desc, @context_class.description
    end

  end

  class SubjectFromLocalTests < BasicSingletonTests
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

  class SubjectFromParentTests < BasicSingletonTests
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
      assert_equal @context_class.subject, subject
    end
  end

end
