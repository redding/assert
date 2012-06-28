require 'assert/options'
require 'assert/runner'

module Assert

  # Setup the default global runner for running tests
  options do
    default_runner Runner
  end

  def self.runner; self.options.runner; end

end
