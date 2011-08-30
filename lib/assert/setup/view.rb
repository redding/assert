require 'assert/options'
require 'assert/view/terminal'

module Assert
  include Assert::Options
  options do
    default_view View::Terminal.new($stdout)
  end

  # Setup the default view to render test results (override in user or package helpers)
  class << self
    def view; self.options.view; end
  end

end
