module Assert; end
class Assert::Context

  module SetupDSL

    def setup_once(&block)
      Assert.suite.setup(&block)
    end
    alias_method :before_once, :setup_once
    alias_method :startup, :setup_once

    def teardown_once(&block)
      Assert.suite.teardown(&block)
    end
    alias_method :after_once, :teardown_once
    alias_method :shutdown, :teardown_once

    # Add a setup block to run before each test or run the list of teardown blocks in given scope
    def setup(scope_or_method_name = nil, &block)
      is_method = scope_or_method_name.kind_of?(String) || scope_or_method_name.kind_of?(Symbol)
      if block_given? || is_method
        # arg is a block or method that needs to be stored as a setup
        self.setups << (block || scope_or_method_name)
      elsif !is_method
        # arg is an instance of this class (the scope for a test),
        # run the setups for this context in the scope
        scope = scope_or_method_name
        # setup parent...
        self.superclass.setup(scope) if self.superclass.respond_to?(:setup)
        # ... before child
        self.setups.each do |setup|
          setup.kind_of?(::Proc) ? scope.instance_eval(&setup) : scope.send(setup)
        end
      end
    end
    alias_method :before, :setup

    # Add a teardown block to run after each test or run the list of teardown blocks in given scope
    def teardown(scope_or_method_name = nil, &block)
      is_method = scope_or_method_name.kind_of?(String) || scope_or_method_name.kind_of?(Symbol)
      if block_given? || is_method
        # arg is a block or method that needs to be stored as a teardown
        self.teardowns << (block || scope_or_method_name)
      elsif !is_method
        # arg is an instance of this class (the scope for a test),
        # run the setups for this context in the scope
        scope = scope_or_method_name
        # teardown child...
        self.teardowns.each do |teardown|
          teardown.kind_of?(::Proc) ? scope.instance_eval(&teardown) : scope.send(teardown)
        end
        # ... before parent
        self.superclass.teardown(scope) if self.superclass.respond_to?(:teardown)
      end
    end
    alias_method :after, :teardown

    protected

    def setups
      @setups ||= []
    end

    def teardowns
      @teardowns ||= []
    end

  end

end
