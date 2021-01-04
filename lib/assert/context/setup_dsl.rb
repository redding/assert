# frozen_string_literal: true

module Assert; end

class Assert::Context
  module SetupDSL
    def setup_once(&block)
      self.suite.setup(&block)
    end
    alias_method :before_once, :setup_once
    alias_method :startup, :setup_once

    def teardown_once(&block)
      self.suite.teardown(&block)
    end
    alias_method :after_once, :teardown_once
    alias_method :shutdown, :teardown_once

    def around(&block)
      self.arounds << block
    end

    def setup(method_name = nil, &block)
      self.setups << (block || method_name)
    end
    alias_method :before, :setup

    def teardown(method_name = nil, &block)
      self.teardowns << (block || method_name)
    end
    alias_method :after, :teardown

    def arounds
      @arounds ||= []
    end

    def setups
      @setups ||= []
    end

    def teardowns
      @teardowns ||= []
    end

    def run_arounds(scope, &run_block)
      context_block = self.arounds.compact.reverse.inject(run_block) do |run_b, around_b|
        Proc.new{ scope.instance_exec(run_b, &around_b) }
      end

      if self.superclass.respond_to?(:run_arounds)
        self.superclass.run_arounds(scope, &context_block)
      else
        context_block.call
      end
    end

    def run_setups(scope)
      # setup the parent...
      self.superclass.run_setups(scope) if self.superclass.respond_to?(:run_setups)
      # ... before you setup the child
      self.setups.compact.each do |setup|
        setup.kind_of?(::Proc) ? scope.instance_eval(&setup) : scope.send(setup)
      end
    end

    def run_teardowns(scope)
      # teardown the child...
      self.teardowns.compact.each do |teardown|
        teardown.kind_of?(::Proc) ? scope.instance_eval(&teardown) : scope.send(teardown)
      end
      # ... before the parent
      self.superclass.run_teardowns(scope) if self.superclass.respond_to?(:run_teardowns)
    end
  end
end
