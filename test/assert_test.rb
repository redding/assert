require 'assert'

require 'assert/options'
require 'assert/view/terminal'
require 'assert/runner'
require 'assert/suite'

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

    should "default the suite option" do
      assert_kind_of Assert::Suite, subject.default_suite
    end

    should "default the runner option" do
      assert_equal Assert::Runner, subject.default_runner
    end

  end
end
