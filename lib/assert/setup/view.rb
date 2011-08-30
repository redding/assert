require 'assert/view/terminal'

module Assert
  # Setup the default view to render test results (override in user or package helpers)
  options do
    default_view View::Terminal.new($stdout)
  end

  class << self
    def view; self.options.view; end
  end

end
