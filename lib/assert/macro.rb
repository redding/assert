module Assert
  class Macro < ::Proc

    # this class is essentially a way to define a custom set of tests using
    # arguments.  When passed as an argument to the 'should' method, a macro
    # will be instance_eval'd in that Assert::Context.

    def initialize(*args, &block)
      raise ArgumentError unless block_given?
      super()
    end

  end
end
