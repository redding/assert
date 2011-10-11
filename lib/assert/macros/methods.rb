require 'assert/macro'

module Assert::Macros
  module Methods

    def self.included(receiver)
      receiver.send(:extend, ClassMethods)
    end

    module ClassMethods

      def have_instance_method(*methods)
        called_from = (methods.last.kind_of?(Array) ? methods.pop : caller).first
        Assert::Macro.new do
          methods.each do |method|
            should "respond to instance method ##{method}", called_from do
              assert_respond_to method, subject, "#{subject.class.name} does not have instance method ##{method}"
            end
          end
        end
      end
      alias_method :have_instance_methods, :have_instance_method

      def have_class_method(*methods)
        called_from = (methods.last.kind_of?(Array) ? methods.pop : caller).first
        Assert::Macro.new do
          methods.each do |method|
            should "respond to class method ##{method}", called_from do
              assert_respond_to method, subject.class, "#{subject.class.name} does not have class method ##{method}"
            end
          end
        end
      end
      alias_method :have_class_methods, :have_class_method

      def have_reader(*methods)
        unless methods.last.kind_of?(Array)
          methods << caller
        end
        have_instance_methods(*methods)
      end
      alias_method :have_readers, :have_reader

      def have_writer(*methods)
        called = methods.last.kind_of?(Array) ? methods.pop : caller
        writer_meths = methods.collect{|m| "#{m}="}
        writer_meths << called
        have_instance_methods(*writer_meths)
      end
      alias_method :have_writers, :have_writer

      def have_accessor(*methods)
        called = methods.last.kind_of?(Array) ? methods.pop : caller
        accessor_meths = methods.collect{|m| [m, "#{m}="]}.flatten
        accessor_meths << called
        have_instance_methods(*accessor_meths)
      end
      alias_method :have_accessors, :have_accessor

    end

  end
end
