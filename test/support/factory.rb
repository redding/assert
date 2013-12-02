module Factory

  def self.context_info_called_from
    "/path/to_file.rb:1234"
  end

  def self.context_info(context_klass = nil)
    Assert::Suite::ContextInfo.new(context_klass || self.context_class, context_info_called_from)
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
    opts, context_info, name = [
      args.last.kind_of?(::Hash) ? args.pop : {},
      args.last.kind_of?(Assert::Suite::ContextInfo) ? args.pop : self.context_info,
      args.last.kind_of?(::String) ? args.pop : 'a test'
    ]

    Assert::Test.new(name, context_info, opts, &block)
  end

  # Generate a skip result for use in testing.

  def self.skip_result(name, exception)
    Assert::Result::Skip.new(Factory.test(name), exception)
  end

end
