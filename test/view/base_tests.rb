require 'assert'
require 'assert/suite'

require 'assert/view/base'
require 'stringio'

module Assert::View

  class BaseTests < Assert::Context
    desc "the base view"
    setup do
      @view = Assert::View::Base.new(Assert::Suite.new, StringIO.new("", "w+"))
    end
    subject{ @view }

    # options
    should have_instance_method :options
    should have_class_method :options

    # accessors, base methods
    should have_accessors :output_io
    should have_imeths :view, :suite, :fire
    should have_imeths :before_load, :after_load, :on_start, :on_finish
    should have_imeths :before_test, :after_test, :on_result

    # common methods
    should have_imeths :run_time, :runner_seed, :count, :tests?, :all_pass?
    should have_imeths :suite_contexts, :ordered_suite_contexts
    should have_imeths :suite_files, :ordered_suite_files
    should have_imeths :result_details_for, :show_result_details?
    should have_imeths :ocurring_result_types, :result_summary_msg
    should have_imeths :all_pass_result_summary_msg, :results_summary_sentence
    should have_imeths :test_count_statement, :result_count_statement
    should have_imeths :to_sentence

  end

  class HandlerTests < Assert::Context
    desc 'the assert view handler'
    subject { Assert::View }

    should have_instance_method :require_user_view
  end

  class BaseOptionsTestx < Assert::Context
    desc "options for the base view"
    subject do
      Assert::View::Base.options
    end

    should "be an Options::Base object" do
      assert_kind_of Assert::Options::Base, subject
    end

    should "default its result abbreviations" do
      assert_equal '.', subject.default_pass_abbrev
      assert_equal 'F', subject.default_fail_abbrev
      assert_equal 'I', subject.default_ignore_abbrev
      assert_equal 'S', subject.default_skip_abbrev
      assert_equal 'E', subject.default_error_abbrev
    end

  end

end
