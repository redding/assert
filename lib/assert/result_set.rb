module Assert
  class ResultSet < ::Array

    attr_accessor :view

    def <<(result)
      super
      if @view && @view.respond_to?(:handle_runtime_result)
        @view.handle_runtime_result(result)
      end
    end

  end
end
