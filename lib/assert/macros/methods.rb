require 'assert/macro'

module Assert::Macros
  module Methods

    def self.included(receiver)
      receiver.send(:extend, ClassMethods)
    end

    module ClassMethods

      def have_instance_method(*methods)
        Assert::Macro.new do
          methods.each do |method|
            should "respond to instance method ##{method}" do
              assert_respond_to subject, method, "#{subject.class.name} does not have instance method ##{method}"
            end
          end
        end
      end
      alias_method :have_instance_methods, :have_instance_method

      def have_class_method(*methods)
        Assert::Macro.new do
          methods.each do |method|
            should "respond to class method ##{method}" do
              assert_respond_to subject.class, method, "#{subject.class.name} does not have class method ##{method}"
            end
          end
        end
      end
      alias_method :have_class_methods, :have_class_method

      def have_reader(*methods)
        have_instance_methods(*methods)
      end
      alias_method :have_readers, :have_reader

      def have_writer(*methods)
        have_instance_methods(*methods.collect{|m| "#{m}="})
      end
      alias_method :have_writers, :have_writer

      def have_accessor(*methods)
        have_instance_methods(*methods.collect{|m| [m, "#{m}="]}.flatten)
      end
      alias_method :have_accessors, :have_accessor

    end

  end
end
