require 'assert'

require 'assert/view/default_view'
require 'assert/runner'
require 'assert/suite'
require 'assert/utils'

module Assert

  class UnitTests < Assert::Context
    desc "the Assert module"
    subject { Assert }

    should have_imeths :view, :suite, :runner, :config, :configure

    should "know its config singleton" do
      assert_same Config, subject.config
    end

    should "map its view, suite and runner to its config" do
      assert_same subject.config.view,   subject.view
      assert_same subject.config.suite,  subject.suite
      assert_same subject.config.runner, subject.runner
    end

    # Note: don't really need to explicitly test the configure/init meths
    # nothing runs as expected if they aren't working

  end

  class ConfigTests < Assert::Context
    desc "the Assert Config singleton"
    subject { Config }

    should have_imeths :suite, :view, :runner, :test_dir, :test_helper, :changed_proc
    should have_imeths :runner_seed, :pp_proc, :use_diff_proc, :run_diff_proc
    should have_imeths :capture_output, :halt_on_fail, :changed_only, :pp_objects
    should have_imeths :debug, :apply

    should "default the view, suite, and runner" do
      assert_kind_of Assert::View::DefaultView, subject.view
      assert_kind_of Assert::Suite,  subject.suite
      assert_kind_of Assert::Runner, subject.runner
    end

    should "default the optional values" do
      assert_not_nil subject.runner_seed
      assert_not_nil subject.pp_proc
      assert_not_nil subject.use_diff_proc
      assert_not_nil subject.run_diff_proc
    end

  end

end
