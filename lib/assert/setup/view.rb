require 'assert/view/terminal'

module Assert
  # Setup the default view to render test results (override in user or package helpers)
  options.default_view View::Terminal.new($stdout)

  class << self
    def view; self.options.view; end
  end

end
