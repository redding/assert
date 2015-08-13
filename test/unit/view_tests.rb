require 'assert'
require 'assert/view'

require 'stringio'
require 'assert/suite'
require 'assert/view_helpers'

class Assert::View

  class UnitTests < Assert::Context
    desc "Assert::View"
    subject { Assert::View }

    should have_instance_method :require_user_view

    should "include the view helpers" do
      assert_includes Assert::ViewHelpers, subject
    end

  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @io     = StringIO.new("", "w+")
      @config = Factory.modes_off_config

      @view = Assert::View.new(@config, @io)
    end
    subject{ @view }

    should have_readers :config
    should have_imeths :view, :is_tty?, :ansi_styled_msg
    should have_imeths :before_load, :after_load
    should have_imeths :on_start, :on_finish, :on_interrupt
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
      assert_equal '.', subject.pass_abbrev
      assert_equal 'F', subject.fail_abbrev
      assert_equal 'I', subject.ignore_abbrev
      assert_equal 'S', subject.skip_abbrev
      assert_equal 'E', subject.error_abbrev
    end

    should "know its config" do
      assert_equal @config, subject.config
    end

    should "expose itself as `view`" do
      assert_equal subject, subject.view
    end

    should "know if it is a tty" do
      assert_equal !!@io.isatty, subject.is_tty?
    end

    should "know how to build ansi styled messages" do
      msg = Factory.string
      result = [:pass, :fail, :error, :skip, :ignore].sample

      Assert.stub(subject, :is_tty?){ false }
      Assert.stub(subject, :styled){ false }
      assert_equal msg, subject.ansi_styled_msg(msg, result)

      Assert.stub(subject, :is_tty?){ false }
      Assert.stub(subject, :styled){ true }
      assert_equal msg, subject.ansi_styled_msg(msg, result)

      Assert.stub(subject, :is_tty?){ true }
      Assert.stub(subject, :styled){ false }
      assert_equal msg, subject.ansi_styled_msg(msg, result)

      Assert.stub(subject, :is_tty?){ true }
      Assert.stub(subject, :styled){ true }
      Assert.stub(subject, "#{result}_styles"){ [] }
      assert_equal msg, subject.ansi_styled_msg(msg, result)

      styles = Factory.integer(3).times.map{ Assert::ViewHelpers::Ansi::CODES.keys.sample }
      Assert.stub(subject, "#{result}_styles"){ styles }
      exp_code = Assert::ViewHelpers::Ansi.code_for(*styles)
      exp = exp_code + msg + Assert::ViewHelpers::Ansi.code_for(:reset)
      assert_equal exp, subject.ansi_styled_msg(msg, result)
    end

  end

end
