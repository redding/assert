# this file is automatically required in when you require 'assert'
# put test helpers here

require 'stringio'

# test/.. (root dir for gem)
$LOAD_PATH.unshift(File.expand_path("../..", __FILE__))

# This is the suite intended to be used in the tests, this is seperate from Assert.suite which is
# the actual suite being used to run the tests, confused? Don't use Assert.suite in your tests,
# use TEST_ASSERT_SUITE
TEST_ASSERT_SUITE = Assert::Suite.new

# This is the test context intended to be used in the tests, and is also used in the context_class
# factory by default. This will ensure any contexts you define in your tests will not be shoved
# onto the the suite running the tests.
class TestContext < Assert::Context
  def self.method_added(meth)
    if meth.to_s =~ Assert::Suite::TEST_METHOD_REGEX
      ci = Assert::Suite::ContextInfo.new(self, Factory.context_info_called_from)
      TEST_ASSERT_SUITE.tests << Assert::Test.new(meth.to_s, ci, meth)
    end
  end
end

# force tests to run without halting on fail (needed for tests to run)
# anywhere we test halt on fail behavior, we take care of it in the specific context
class Assert::Context
  def setup
    Assert.config.halt_on_fail false
    # Note: don't mess with `Assert.config.output` in this setup block - it will
    # break the capture output tests.  If you really need to set it one way or
    # another, do it in the `.assert.rb` local settings file.
  end
end

module Factory
  class << self

    def context_info_called_from
      "/path/to_file.rb:1234"
    end

    def context_info(context_class)
      Assert::Suite::ContextInfo.new(context_class, context_info_called_from)
    end
    # Generates an anonymous class inherited from whatever you pass or TextContext by default. This
    # provides a common interface for all context classes to be generated in the tests.
    def context_class(inherit_from = nil, &block)
      inherit_from ||= TestContext
      klass = Class.new(inherit_from, &block)
      default = (const_name = "FactoryAssertContext").dup
      while(Object.const_defined?(const_name)) do
        const_name = "FactoryAssertContext#{rand(Time.now.to_i)}"
      end
      Object.const_set(const_name, klass)
      klass
    end

    # Common interface for generating a new test, takes args and a block, will default everything
    # if you need a no-op test.
    def test(*args, &block)
      name = (args[0] || "a test").to_s
      context_info = args[1] || self.context_info(self.context_class)
      test_block = (block || args[2] || ::Proc.new{})

      Assert::Test.new(name, context_info, &test_block)
    end

    # Common interface for generating a new skip result
    def skip_result(name, exception)
      Assert::Result::Skip.new(Factory.test(name), exception)
    end

  end
end
