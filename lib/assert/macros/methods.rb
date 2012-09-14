require 'assert/macro'

module Assert::Macros
  module Methods

    def self.included(receiver)
      receiver.send(:extend, ClassMethods)
    end

    module ClassMethods

      def have_instance_method(*methods)
        called_from = (methods.last.kind_of?(Array) ? methods.pop : caller).first
        name = "have instance methods: #{methods.map{|m| "'#{m}'"}.join(', ')}"
        Assert::Macro.new(name) do
          methods.each do |method|
            should "respond to instance method ##{method}", called_from do
              assert_respond_to method, subject, "#{subject.class.name} does not have instance method ##{method}"
            end
          end
        end
      end
      alias_method :have_instance_methods, :have_instance_method
      alias_method :have_imeth, :have_instance_method
      alias_method :have_imeths, :have_instance_method

      def not_have_instance_method(*methods)
        called_from = (methods.last.kind_of?(Array) ? methods.pop : caller).first
        name = "not have instance methods: #{methods.map{|m| "'#{m}'"}.join(', ')}"
        Assert::Macro.new(name) do
          methods.each do |method|
            should "not respond to instance method ##{method}", called_from do
              assert_not_respond_to method, subject, "#{subject.class.name} has instance method ##{method}"
            end
          end
        end
      end
      alias_method :not_have_instance_methods, :not_have_instance_method
      alias_method :not_have_imeth, :not_have_instance_method
      alias_method :not_have_imeths, :not_have_instance_method

      def have_class_method(*methods)
        called_from = (methods.last.kind_of?(Array) ? methods.pop : caller).first
        name = "have class methods: #{methods.map{|m| "'#{m}'"}.join(', ')}"
        Assert::Macro.new(name) do
          methods.each do |method|
            should "respond to class method ##{method}", called_from do
              assert_respond_to method, subject.class, "#{subject.class.name} does not have class method ##{method}"
            end
          end
        end
      end
      alias_method :have_class_methods, :have_class_method
      alias_method :have_cmeth, :have_class_method
      alias_method :have_cmeths, :have_class_method

      def not_have_class_method(*methods)
        called_from = (methods.last.kind_of?(Array) ? methods.pop : caller).first
        name = "not have class methods: #{methods.map{|m| "'#{m}'"}.join(', ')}"
        Assert::Macro.new(name) do
          methods.each do |method|
            should "not respond to class method ##{method}", called_from do
              assert_not_respond_to method, subject.class, "#{subject.class.name} has class method ##{method}"
            end
          end
        end
      end
      alias_method :not_have_class_methods, :not_have_class_method
      alias_method :not_have_cmeth, :not_have_class_method
      alias_method :not_have_cmeths, :not_have_class_method

      def have_reader(*methods)
        methods << caller if !methods.last.kind_of?(Array)
        have_instance_methods(*methods)
      end
      alias_method :have_readers, :have_reader

      def not_have_reader(*methods)
        methods << caller if !methods.last.kind_of?(Array)
        not_have_instance_methods(*methods)
      end
      alias_method :not_have_readers, :not_have_reader

      def have_writer(*methods)
        called = methods.last.kind_of?(Array) ? methods.pop : caller
        writer_meths = methods.collect{|m| "#{m}="}
        writer_meths << called
        have_instance_methods(*writer_meths)
      end
      alias_method :have_writers, :have_writer

      def not_have_writer(*methods)
        called = methods.last.kind_of?(Array) ? methods.pop : caller
        writer_meths = methods.collect{|m| "#{m}="}
        writer_meths << called
        not_have_instance_methods(*writer_meths)
      end
      alias_method :not_have_writers, :not_have_writer

      def have_accessor(*methods)
        called = methods.last.kind_of?(Array) ? methods.pop : caller
        accessor_meths = methods.collect{|m| [m, "#{m}="]}.flatten
        accessor_meths << called
        have_instance_methods(*accessor_meths)
      end
      alias_method :have_accessors, :have_accessor

      def not_have_accessor(*methods)
        called = methods.last.kind_of?(Array) ? methods.pop : caller
        accessor_meths = methods.collect{|m| [m, "#{m}="]}.flatten
        accessor_meths << called
        not_have_instance_methods(*accessor_meths)
      end
      alias_method :not_have_accessors, :not_have_accessor

    end

  end
end
