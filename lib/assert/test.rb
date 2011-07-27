module Assert
  class Test

    attr_reader :name, :assertions
    attr_reader :setups, :teardowns

    def initialize(name, &code)
      @name = name
      @code = code
      [:assertions, :setups, :teardowns].each do |a|
        instance_variable_set("@#{a}", [])
      end
    end

  end
end