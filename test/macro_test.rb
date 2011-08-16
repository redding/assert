require 'assert'

require 'assert/macro'

class Assert::Macro

  class BaseTest < Assert::Context
    desc "a macro"
    subject { Assert::Macro.new {} }

    should "be a Proc" do
      assert_kind_of ::Proc, subject
    end

    should "complain if you create a macro without a block" do
      assert_raises ArgumentError do
        Assert::Macro.new
      end
    end
  end

  class InstanceMethodsTest < Assert::Context
    desc "a class with instance methods"
    subject do
      class ::InstExample
        (1..6).each do |i|
          define_method("method_#{i}") {}
        end
      end
      ::InstExample.new
    end

    should have_instance_method :method_1
    should have_instance_method :method_2, :method_3
    should have_instance_methods :method_4
    should have_instance_methods :method_5, :method_6
  end

  class ClassMethodsTest < Assert::Context
    desc "a class with class methods"
    subject do
      class ::ClassExample
        class << self
          (1..6).each do |i|
            define_method("method_#{i}") {}
          end
        end
      end
      ::ClassExample.new
    end

    should have_class_method :method_1
    should have_class_method :method_2, :method_3
    should have_class_methods :method_4
    should have_class_methods :method_5, :method_6
  end

end
