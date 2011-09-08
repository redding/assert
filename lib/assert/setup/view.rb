require 'assert/view/default_view'

module Assert

  # Setup the default view, rendering on $stdout
  # (override in user or package helpers)
  options do
    default_view View::DefaultView.new($stdout)
  end

  # setup the global Assert.view method
  class << self
    def view; self.options.view; end
  end

end
