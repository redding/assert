require 'assert'
require 'assert/setup/view'

module Assert

  class DefaultViewTests < Assert::Context
    desc "assert's default view"
    subject { Assert.options.default_view }

    should "be the AnsiTerminal" do
      assert_kind_of AnsiTerminal, subject
    end

  end

  class OptionsTests < DefaultViewTests
    desc "options"
    subject do
      Assert.options.default_view.options
    end

    should "be an Options::Base object" do
      assert_kind_of Assert::Options::Base, subject
    end

    should "default the template" do
      assert_equal 'assert.ansi', subject.default_template
    end

    should "default the styled option" do
      assert_equal false, subject.default_styled
    end

    should "default its result styles" do
      assert_equal :green, subject.default_passed_styles
      assert_equal [:red, :bold], subject.default_failed_styles
      assert_equal :magenta, subject.default_ignored_styles
      assert_equal :cyan, subject.default_skipped_styles
      assert_equal [:yellow, :bold], subject.default_errored_styles
    end

  end

end
