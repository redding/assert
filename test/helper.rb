# this file is automatically required in when you require 'test_belt'
# put test helpers here

lib_path = File.join(File.expand_path("../..", __FILE__), 'lib')
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
require 'assert'

Assert::View::Terminal.options do
  styled true
end

# This is the suite intended to be used in the tests, this is seperate from Assert.suite which is
# the actual suite being used to run the tests, confused? Don't use Assert.suite in your tests,
# use TEST_ASSERT_SUITE
TEST_ASSERT_SUITE = Assert::Suite.new

# This is the test context intended to be used in the tests, and is also used in the context_class
# factory by default. This will ensure any contexts you define in your tests will not be shoved
# onto the the suite running the tests.
class TestContext < Assert::Context
  def self.inherited(klass)
    TEST_ASSERT_SUITE << klass
  end
end

module Factory
  class << self

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
      context_class = args[1] || self.context_class
      block ||= (args[2] || lambda{ })

      Assert::Test.new(name, context_class, &block)
    end

    # Common interface for generating a new skip result
    def skip_result(name, exception)
      Assert::Result::Skip.new(name, exception)
    end

  end
end
