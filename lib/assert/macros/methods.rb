require 'assert/macro'

module Assert::Macros
  module Methods

    def self.included(receiver)
      receiver.send(:extend, ClassMethods)
    end

    module ClassMethods

      def have_instance_method(*methods)
        Assert::Macro.new do
          methods.collect do |method|
            should "respond to instance method ##{method}" do
              assert_respond_to subject, method, "#{subject.class.name} does not have instance method ##{method}"
            end
          end
        end
      end
      alias_method :have_instance_methods, :have_instance_method

      def have_class_method(*methods)
        Assert::Macro.new do
          methods.collect do |method|
            should "respond to class method ##{method}" do
              assert_respond_to subject.class, method, "#{subject.class.name} does not have class method ##{method}"
            end
          end
        end
      end
      alias_method :have_class_methods, :have_class_method

    end

  end
end
