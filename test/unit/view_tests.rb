require 'assert'
require 'assert/view/base'

require 'stringio'
require 'assert/suite'
require 'assert/view_helpers'

class Assert::View::Base

  class UnitTests < Assert::Context
    desc "Assert::View::Base"
    setup do
      @io = StringIO.new("", "w+")
      @config = Factory.modes_off_config
      @view = Assert::View::Base.new(@io, @config, @config.suite)
    end
    subject{ @view }

    should have_imeths :is_tty?, :view, :config, :suite, :fire
    should have_imeths :before_load, :after_load
    should have_imeths :on_start, :on_finish, :on_interrupt
    should have_imeths :before_test, :after_test, :on_result

    should "include the view helpers" do
      assert_includes Assert::ViewHelpers, subject.class
    end

    should "default its result abbreviations" do
      assert_equal '.', subject.pass_abbrev
      assert_equal 'F', subject.fail_abbrev
      assert_equal 'I', subject.ignore_abbrev
      assert_equal 'S', subject.skip_abbrev
      assert_equal 'E', subject.error_abbrev
    end

    should "know if it is a tty" do
      assert_equal !!@io.isatty, subject.is_tty?
    end

  end

  class HandlerTests < Assert::Context
    desc "Assert::View"
    subject { Assert::View }

    should have_instance_method :require_user_view

  end

end
