module Assert
  module Options

    class Base
      def method_missing(method, *args, &block)
        if args.empty?
          self.instance_variable_get("@#{method}")
        else
          self.instance_variable_set("@#{method}", (args.size == 1 ? args.first : args))
        end
      end

    end

    def self.included(receiver)
      receiver.send(:class_variable_set, "@@options", Base.new)
      receiver.send(:extend, ClassMethods)
      receiver.send(:include, InstanceMethods)
    end

    module ClassMethods
      def options(&block)
        options = self.send(:class_variable_get, "@@options")
        if block_given?
          options.instance_eval(&block)
        else
          options
        end
      end
    end

    module InstanceMethods
      def options
        self.class.options
      end
    end

  end
end
