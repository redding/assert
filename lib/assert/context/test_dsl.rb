require 'assert/context_info'
require 'assert/macro'
require 'assert/suite'
require 'assert/test'

module Assert; end
class Assert::Context

  module TestDSL

    def test(desc_or_macro, called_from = nil, first_caller = nil, &block)
      if desc_or_macro.kind_of?(Assert::Macro)
        instance_eval(&desc_or_macro)
      elsif block_given?
        # create a test from the given code block
        self.suite.tests << Assert::Test.for_block(
          desc_or_macro.kind_of?(Assert::Macro) ? desc_or_macro.name : desc_or_macro,
          Assert::ContextInfo.new(self, called_from, first_caller || caller.first),
          self.suite.config,
          &block
        )
      else
        test_eventually(desc_or_macro, called_from, first_caller || caller.first, &block)
      end
    end

    def test_eventually(desc_or_macro, called_from = nil, first_caller = nil, &block)
      # create a test from a proc that just skips
      ci = Assert::ContextInfo.new(self, called_from, first_caller || caller.first)
      self.suite.tests << Assert::Test.for_block(
        desc_or_macro.kind_of?(Assert::Macro) ? desc_or_macro.name : desc_or_macro,
        ci,
        self.suite.config,
        &proc { skip('TODO', ci.called_from) }
      )
    end
    alias_method :test_skip, :test_eventually

    def should(desc_or_macro, called_from = nil, first_caller = nil, &block)
      if !desc_or_macro.kind_of?(Assert::Macro)
        desc_or_macro = "should #{desc_or_macro}"
      end
      test(desc_or_macro, called_from, first_caller || caller.first, &block)
    end

    def should_eventually(desc_or_macro, called_from = nil, first_caller = nil, &block)
      if !desc_or_macro.kind_of?(Assert::Macro)
        desc_or_macro = "should #{desc_or_macro}"
      end
      test_eventually(desc_or_macro, called_from, first_caller || caller.first, &block)
    end
    alias_method :should_skip, :should_eventually

  end

end
