# this file is automatically required when you run `assert`
# put any test helpers here

# add the root dir to the load path
ROOT_PATH = File.expand_path("../..", __FILE__)
$LOAD_PATH.unshift(ROOT_PATH)

# require pry for debugging (`binding.pry`)
require 'pry'

# Force tests to run without halting on failures (needed so all tests will run
# properly).  For halt on fail behavior testing, the context of those tests
# configures Assert temporarily as needed.

class Assert::Context
  def setup
    Assert.config.halt_on_fail false
    # Note: don't mess with the `capture_output` setting in this setup block. Doing
    # so will break the capture output tests.  If you really need to set it one
    # way or the other, do so in the `.assert.rb` local settings file.
  end

  # a context for use in testing all the different context singleton methods
  class ContextSingletonTests < Assert::Context
    desc "Assert context singleton"
    setup do
      @orig_assert_suite = Assert.suite
      Assert.config.suite TEST_ASSERT_SUITE
      @test = Factory.test
      @context_class = @test.context_class
    end
    teardown do
      TEST_ASSERT_SUITE.tests.clear
      Assert.config.suite @orig_assert_suite
    end
    subject{ @context_class }

  end

end


# A Suite for use in the tests.  It is seperate from `Assert.suite`
# (which is the actual suite being used to run the tests). Don't use
# `Assert.suite` in your tests, use TEST_ASSERT_SUITE

TEST_ASSERT_SUITE = Assert::Suite.new

# A context for use in the tests and also in the `context_class` factory. This
# will ensure any contexts defined as part of the tests will add their methods
# to `TEST_ASSERT_SUITE`

class TestContext < Assert::Context
  def self.method_added(meth)
    if meth.to_s =~ Assert::Suite::TEST_METHOD_REGEX
      ci = Assert::Suite::ContextInfo.new(self, Factory.context_info_called_from)
      TEST_ASSERT_SUITE.tests << Assert::Test.new(meth.to_s, ci, meth)
    end
  end
end

module Factory

  def self.context_info_called_from
    "/path/to_file.rb:1234"
  end

  def self.context_info(context_class)
    Assert::Suite::ContextInfo.new(context_class, context_info_called_from)
  end

  # Generate an anonymous `Context` inherited from `TestContext` by default.
  # This provides a common interface for all contexts used in testing.

  def self.context_class(inherit_from=nil, &block)
    inherit_from ||= TestContext
    klass = Class.new(inherit_from, &block)
    default = (const_name = "FactoryAssertContext").dup

    while(Object.const_defined?(const_name)) do
      const_name = "FactoryAssertContext#{rand(Time.now.to_i)}"
    end
    Object.const_set(const_name, klass)
    klass
  end

  # Generate a no-op test for use in testing.

  def self.test(*args, &block)
    name = (args[0] || "a test").to_s
    context_info = args[1] || self.context_info(self.context_class)
    test_block = (block || args[2] || ::Proc.new{})

    Assert::Test.new(name, context_info, &test_block)
  end

  # Generate a skip result for use in testing.

  def self.skip_result(name, exception)
    Assert::Result::Skip.new(Factory.test(name), exception)
  end

end
