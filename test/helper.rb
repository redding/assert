# this file is automatically required in when you require 'test_belt'
# put test helpers here

lib_path = File.join(File.expand_path("../..", __FILE__), 'lib')
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
require 'assert'

module Factory
  class << self

    def context_class(*args, &block)
      Class.new(Assert::Context, &block)
    end
    
    def test(*args, &block)
      name = (args[0] || "a test").to_s
      context_class = args[1] || self.context_class
      block ||= lambda{ }
      
      Assert::Test.new(name, block, context_class)
    end

  end
end
