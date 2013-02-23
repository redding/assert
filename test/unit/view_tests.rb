require 'assert'
require 'assert/suite'
require 'assert/view/base'
require 'stringio'

module Assert::View

  class BaseTests < Assert::Context
    desc "the base view"
    setup do
      @view = Assert::View::Base.new(StringIO.new("", "w+"), Assert::Suite.new)
    end
    subject{ @view }

    # accessors, base methods
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

    should "default its result abbreviations" do
      assert_equal '.', subject.pass_abbrev
      assert_equal 'F', subject.fail_abbrev
      assert_equal 'I', subject.ignore_abbrev
      assert_equal 'S', subject.skip_abbrev
      assert_equal 'E', subject.error_abbrev
    end

  end

  class HandlerTests < Assert::Context
    desc 'the assert view handler'
    subject { Assert::View }

    should have_instance_method :require_user_view
  end

end
