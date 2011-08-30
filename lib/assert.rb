require 'assert/options'

module Assert
  include Assert::Options
  options {}
end

require 'assert/setup'
require 'assert/autorun'

Assert::Helpers.load(caller)
Assert.autorun
