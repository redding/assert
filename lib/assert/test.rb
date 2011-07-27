module Assert
  class Test
    # TODO: subj meth calling to context
    # instance eval subject blocks in order
    # same for

    attr_reader :name, :assertions

    def initialize(name, &code)
      @name = name
      @code = code
      [:assertions].each do |a|
        instance_variable_set("@#{a}", [])
      end
    end

  end
end