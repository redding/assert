require 'assert/context'
require 'assert/suite'

module Assert

  # Setup the default global suite for collecting tests as contexts are defined
  options do
    default_suite Suite.new
  end

  def self.suite; self.options.suite; end

end
