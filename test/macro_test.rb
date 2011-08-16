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
        (1..6).each {|i| define_method("method_#{i}") {}}
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
          (1..6).each {|i| define_method("method_#{i}") {}}
        end
      end
      ::ClassExample.new
    end

    should have_class_method :method_1
    should have_class_method :method_2, :method_3
    should have_class_methods :method_4
    should have_class_methods :method_5, :method_6
  end

  class ReadersTest < Assert::Context
    desc "a class with readers"
    subject do
      class ::ReaderExample
        (1..6).each {|i| attr_reader "method_#{i}"}
      end
      ::ReaderExample.new
    end

    should have_reader :method_1
    should have_reader :method_2, :method_3
    should have_readers :method_4
    should have_readers :method_5, :method_6
  end

  class WritersTest < Assert::Context
    desc "a class with writers"
    subject do
      class ::WriterExample
        (1..6).each {|i| attr_writer "method_#{i}"}
      end
      ::WriterExample.new
    end

    should have_writer :method_1
    should have_writer :method_2, :method_3
    should have_writers :method_4
    should have_writers :method_5, :method_6
  end

  class AccessorsTest < Assert::Context
    desc "a class with accessors"
    subject do
      class ::AccessorExample
        (1..6).each {|i| attr_accessor "method_#{i}"}
      end
      ::AccessorExample.new
    end

    should have_accessor :method_1
    should have_accessor :method_2, :method_3
    should have_accessors :method_4
    should have_accessors :method_5, :method_6
  end

end
