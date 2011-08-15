module Assert
  class Macro < ::Proc

    # this class is essentially a way to define a custom set of tests using
    # arguments

    def initialize(*args, &block)
      raise ArgumentError unless block_given?
      super()
    end

  end
end
