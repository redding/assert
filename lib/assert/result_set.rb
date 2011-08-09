module Assert
  class ResultSet < ::Array

    attr_accessor :view

    def <<(result)
      super
      if @view && @view.respond_to?(:print_result)
        @view.print_result(result)
      end
    end

  end
end
