require "assert"
require "assert/context/subject_dsl"

module Assert::Context::SubjectDSL

  class UnitTests < Assert::Context
    desc "Assert::Context::SubjectDSL"
    subject{ @context_class }
  end

  class DescriptionsTests < UnitTests
    desc "`descriptions` method"
    setup do
      descs = @descs = ["something amazing", "it really is"]
      @context_class = Factory.modes_off_context_class do
        descs.each{ |text| desc text }
      end
    end

    should "return a collection containing any descriptions defined on the class" do
      assert_equal @descs, subject.send(:descriptions)
    end
  end

  class DescriptionTests < UnitTests
    desc "`description` method"
    setup do
      parent_text = @parent_desc = "parent description"
      @parent_class = Factory.modes_off_context_class do
        desc parent_text
      end
      text = @desc = "and the description for this context"
      @context_class = Factory.modes_off_context_class(@parent_class) do
        desc text
      end
    end

    should "return a string of all the inherited descriptions" do
      exp_desc = "parent description and the description for this context"
      assert_equal exp_desc, @context_class.description
    end
  end

  class SubjectFromLocalTests < UnitTests
    desc "`subject` method using local context"
    setup do
      subject_block = @subject_block = ::Proc.new{ @something }
      @context_class = Factory.modes_off_context_class do
        subject(&subject_block)
      end
    end

    should "set the subject block on the context class" do
      assert_equal @subject_block, @context_class.subject
    end
  end

  class SubjectFromParentTests < UnitTests
    desc "`subject` method using parent context"
    setup do
      parent_block = @parent_block = ::Proc.new{ @something }
      @parent_class = Factory.modes_off_context_class do
        subject(&parent_block)
      end
      @context_class = Factory.modes_off_context_class(@parent_class)
    end

    should "default to it's parents subject block" do
      assert_equal @parent_block, @context_class.subject
    end
  end
end
