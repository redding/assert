require 'assert/macro'
require 'assert/suite'
require 'assert/test'

module Assert; end
class Assert::Context

  module TestDSL

    def test(desc_or_macro, called_from=nil, first_caller=nil, &block)
      if desc_or_macro.kind_of?(Assert::Macro)
        instance_eval(&desc_or_macro)
      elsif block_given?
        ci = Assert::Suite::ContextInfo.new(self, called_from, first_caller || caller.first)
        test_name = desc_or_macro

        # create a test from the given code block
        Assert.suite.tests << Assert::Test.new(test_name, ci, Assert.config, &block)
      else
        test_eventually(desc_or_macro, called_from, first_caller || caller.first, &block)
      end
    end

    def test_eventually(desc_or_macro, called_from=nil, first_caller=nil, &block)
      ci = Assert::Suite::ContextInfo.new(self, called_from, first_caller || caller.first)
      test_name = desc_or_macro.kind_of?(Assert::Macro) ? desc_or_macro.name : desc_or_macro
      skip_block = block.nil? ? Proc.new { skip 'TODO' } : Proc.new { skip }

      # create a test from a proc that just skips
      Assert.suite.tests << Assert::Test.new(test_name, ci, Assert.config, &skip_block)
    end
    alias_method :test_skip, :test_eventually

    def should(desc_or_macro, called_from=nil, first_caller=nil, &block)
      if !desc_or_macro.kind_of?(Assert::Macro)
        desc_or_macro = "should #{desc_or_macro}"
      end
      test(desc_or_macro, called_from, first_caller || caller.first, &block)
    end

    def should_eventually(desc_or_macro, called_from=nil, first_caller=nil, &block)
      if !desc_or_macro.kind_of?(Assert::Macro)
        desc_or_macro = "should #{desc_or_macro}"
      end
      test_eventually(desc_or_macro, called_from, first_caller || caller.first, &block)
    end
    alias_method :should_skip, :should_eventually

  end

end
