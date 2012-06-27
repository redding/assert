module Assert
  class ResultSet < ::Array

    attr_accessor :callback

    def initialize(callback=nil)
      @callback = callback
      super()
    end

    def <<(result)
      super
      @callback.call(result) if @callback
    end

  end
end
