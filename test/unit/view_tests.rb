require "assert"
require "assert/view"

require "stringio"
require "assert/config_helpers"
require "assert/suite"
require "assert/view_helpers"

class Assert::View
  class UnitTests < Assert::Context
    desc "Assert::View"
    subject { Assert::View }

    should have_instance_method :require_user_view

    should "include the config helpers" do
      assert_includes Assert::ConfigHelpers, subject
    end

    should "include the view helpers" do
      assert_includes Assert::ViewHelpers, subject
    end
  end

  class InitTests < UnitTests
    desc "when init"
    subject { view1 }

    let(:io1)     { StringIO.new("", "w+") }
    let(:config1) { Factory.modes_off_config }
    let(:view1)   { Assert::View.new(config1, io1) }

    should have_readers :config
    should have_imeths :view, :is_tty?
    should have_imeths :before_load, :after_load
    should have_imeths :on_start, :on_finish, :on_info, :on_interrupt
    should have_imeths :before_test, :after_test, :on_result

    should "default its style options" do
      assert_false subject.styled

      assert_nil subject.pass_styles
      assert_nil subject.fail_styles
      assert_nil subject.error_styles
      assert_nil subject.skip_styles
      assert_nil subject.ignore_styles
    end

    should "default its result abbreviations" do
      assert_equal ".", subject.pass_abbrev
      assert_equal "F", subject.fail_abbrev
      assert_equal "I", subject.ignore_abbrev
      assert_equal "S", subject.skip_abbrev
      assert_equal "E", subject.error_abbrev
    end

    should "know its config" do
      assert_equal config1, subject.config
    end

    should "override the config helper's view value with itself" do
      assert_equal subject, subject.view
    end

    should "know if it is a tty" do
      assert_equal !!io1.isatty, subject.is_tty?
    end
  end
end
