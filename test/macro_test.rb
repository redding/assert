require 'assert'

require 'assert/macro'

class Assert::Macro

  class BaseTest < Assert::Context
    desc "a macro"
    subject { Assert::Macro.new {} }

    should "be a Proc" do
      assert_kind_of ::Proc, subject
    end

    should "complain if you create a macro without a block" do
      assert_raises ArgumentError do
        Assert::Macro.new
      end
    end
  end

end
