require 'assert/view/terminal'

module Assert

  # Setup the default view to render test results (override in user or package helpers)
  @@view = View::Terminal.new(self.suite, $stdout)
  class << self
    def view; @@view; end
  end

end
