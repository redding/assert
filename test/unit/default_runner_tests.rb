require "assert"
require "assert/default_runner"

require "assert/runner"

class Assert::DefaultRunner
  class UnitTests < Assert::Context
    desc "Assert::DefaultRunner"
    setup do
      @config = Factory.modes_off_config
      @runner = Assert::DefaultRunner.new(@config)
    end
    subject{ @runner }
  end
end
