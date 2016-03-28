require 'assert'
require 'assert/config_helpers'

require 'assert/config'

module Assert::ConfigHelpers

  class UnitTests < Assert::Context
    desc "Assert::ConfigHelpers"
    setup do
      @helpers_class = Class.new do
        include Assert::ConfigHelpers

        def config
          # use the assert config since it has tests, contexts, etc
          # also maybe use a fresh config that is empty
          @config ||= [Assert.config, Assert::Config.new].sample
        end
      end
      @helpers = @helpers_class.new
    end
    subject{ @helpers }

    should have_imeths :runner, :suite, :view
    should have_imeths :runner_seed, :count, :tests?, :all_pass?
    should have_imeths :formatted_run_time
    should have_imeths :formatted_test_rate, :formatted_result_rate
    should have_imeths :show_test_profile_info?, :show_test_verbose_info?
    should have_imeths :ocurring_result_types

    should "know the config's runner, suite and view" do
      assert_equal subject.config.runner, subject.runner
      assert_equal subject.config.suite,  subject.suite
      assert_equal subject.config.view,   subject.view
    end

    should "know its runner seed" do
      assert_equal subject.config.runner_seed, subject.runner_seed
    end

    should "know how to count things on the suite" do
      thing = [:pass, :fail, :results, :tests].sample
      assert_equal subject.config.suite.count(thing), subject.count(thing)
    end

    should "know if it has tests or not" do
      exp = subject.count(:tests) > 0
      assert_equal exp, subject.tests?
    end

    should "know its formatted run time, test rate and result rate" do
      format = '%.6f'

      exp = format % subject.config.suite.run_time
      assert_equal exp, subject.formatted_run_time(format)

      exp = format % subject.config.suite.test_rate
      assert_equal exp, subject.formatted_test_rate(format)

      exp = format % subject.config.suite.result_rate
      assert_equal exp, subject.formatted_result_rate(format)
    end

    should "know whether to show test profile info" do
      assert_equal !!subject.config.profile, subject.show_test_profile_info?
    end

    should "know whether to show verbose info" do
      assert_equal !!subject.config.verbose, subject.show_test_verbose_info?
    end

    should "know what result types occur in a suite's results" do
      exp = [:pass, :fail, :ignore, :skip, :error].select do |result_sym|
        subject.count(result_sym) > 0
      end
      assert_equal exp, subject.ocurring_result_types
    end

  end

end
