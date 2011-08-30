require 'assert'

require 'assert/options'
require 'assert/view/terminal'

module Assert
  class AssertOptionsTest < Assert::Context
    desc "options for Assert"
    subject { Assert.options }

    should "be an Options::Base object" do
      assert_kind_of Assert::Options::Base, subject
    end

    should "default the view option" do
      assert_kind_of Assert::View::Terminal, subject.default_view
    end

  end
end
