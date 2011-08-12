require 'assert/context'
require 'assert/suite'

module Assert

  # Setup the default global suite for collecting tests as contexts are defined
  @@suite = Suite.new
  class << self
    def suite; @@suite; end
  end

end
