require 'assert/options'
require 'assert/runner'

module Assert
  # Setup the default global runner for running tests
  options do
    default_runner Runner
  end

  class << self
    def runner; self.options.runner; end
  end

end
