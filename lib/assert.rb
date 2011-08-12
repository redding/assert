require 'assert/setup/suite'
require 'assert/setup/view'

require 'assert/setup/helpers'
require 'assert/setup/autorun'

Assert::Helpers.load(caller)
Assert.autorun
