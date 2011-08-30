require 'assert/context'
require 'assert/suite'

module Assert
  # Setup the default global suite for collecting tests as contexts are defined
  options.default_suite Suite.new

  class << self
    def suite
      self.options.suite
    end
  end

end
