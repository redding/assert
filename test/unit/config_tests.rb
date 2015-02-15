require 'assert'
require 'assert/config'

class Assert::Config

  class UnitTests < Assert::Context
    desc "Assert::Config"
    setup do
      @config = Assert::Config.new
    end
    subject{ @config }

    should have_imeths :suite, :view, :runner
    should have_imeths :test_dir, :test_helper, :test_file_suffixes, :runner_seed
    should have_imeths :changed_proc, :pp_proc, :use_diff_proc, :run_diff_proc
    should have_imeths :capture_output, :halt_on_fail, :changed_only, :pp_objects
    should have_imeths :debug, :profile, :verbose
    should have_imeths :apply

    should "default the view, suite, and runner" do
      assert_kind_of Assert::View::DefaultView, subject.view
      assert_kind_of Assert::Suite,  subject.suite
      assert_kind_of Assert::Runner, subject.runner
    end

    should "default the test dir/helper/suffixes/seed" do
      assert_equal 'test', subject.test_dir
      assert_equal 'helper.rb', subject.test_helper
      assert_equal ['_tests.rb', "_test.rb"], subject.test_file_suffixes
      assert_not_nil subject.runner_seed
    end

    should "default the procs" do
      assert_not_nil subject.changed_proc
      assert_not_nil subject.pp_proc
      assert_not_nil subject.use_diff_proc
      assert_not_nil subject.run_diff_proc
    end

    should "default the mode flags" do
      assert_not subject.capture_output
      assert     subject.halt_on_fail
      assert_not subject.changed_only
      assert_not subject.pp_objects
      assert_not subject.debug
      assert_not subject.profile
      assert_not subject.verbose
    end

    should "apply settings given from a hash" do
      assert subject.halt_on_fail
      subject.apply(:halt_on_fail => false)
      assert_not subject.halt_on_fail

      assert Assert::Config.new.halt_on_fail
      assert_not Assert::Config.new(:halt_on_fail => false).halt_on_fail
    end

  end

end
