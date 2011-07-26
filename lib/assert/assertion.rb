module Assert
  class Assertion

    attr_reader :statement, :description, :result

    def initialize(description="", &block)
      @description = description
      @statement = block
    end

  end
end