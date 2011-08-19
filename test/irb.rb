# require in any test helper and load user settings
require 'assert/setup'
Assert::Helpers.load(caller)

# this file is required in when the 'irb' rake test is run.
# put any IRB setup code here
