module Assert::View
  module Renderer

    # this module is mixed in to the Assert::View::Base class

    def self.included(receiver)
      receiver.send(:extend, ClassMethods)
    end

    module ClassMethods

      # make any helper methods available to the template
      def helper(helper_klass)
        TemplatedView.send(:include, helper_klass)
      end

      # set the view's template by passing a block, get by calling w/ no args
      def template(&block)
        if block
          @template = block
        else
          @template
        end
      end

    end

    class TemplatedView

      # this class is used as the scope to instance_eval the view's template
      # proc in which write the output

      def initialize(*args)
        # get the io to write to
        @io = args.pop

        # apply any given data to templated view scope
        data = args.last.kind_of?(::Hash) ? args.pop : {}
        if (data.keys.map(&:to_s) & self.public_methods.map(&:to_s)).size > 0
          raise ArgumentError, "data conflicts with template public methods."
        end
        metaclass = class << self; self; end
        data.each {|key, value| metaclass.class_eval { define_method(key){value} }}

        # get the template source proc to instance_eval
        @source = args.pop || Proc.new {}
      end

      def render!
        instance_eval(&@source)
      end

      # method to output to the io stream
      def _(data="", nl=true)
        @io << "#{data.to_s}#{nl ? "\n" : ""}"
      end

    end

    # this method is required by assert and is called by the test runner.
    # this renders the templated view using the view's template
    def render(*args, &runner)
      TemplatedView.new(self.class.template, {
        :view => self,
        :runner => runner
      }, self.output_io).render!
    end

  end
end
