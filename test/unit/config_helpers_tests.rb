require "assert"
require "assert/config_helpers"

require "assert/config"

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
    should have_imeths :runner_seed, :single_test?, :single_test_file_line
    should have_imeths :tests_to_run?, :tests_to_run_count
    should have_imeths :test_count, :result_count, :pass_result_count
    should have_imeths :fail_result_count, :error_result_count
    should have_imeths :skip_result_count, :ignore_result_count
    should have_imeths :all_pass?, :formatted_run_time
    should have_imeths :formatted_test_rate, :formatted_result_rate
    should have_imeths :formatted_suite_run_time
    should have_imeths :formatted_suite_test_rate, :formatted_suite_result_rate
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

    should "know if it is in single test mode" do
      Assert.stub(subject.config, :single_test?){ true }
      assert_true subject.single_test?

      Assert.stub(subject.config, :single_test?){ false }
      assert_false subject.single_test?
    end

    should "know its single test file line" do
      exp = subject.config.single_test_file_line
      assert_equal exp, subject.single_test_file_line
    end

    should "know its tests-to-run attrs" do
      exp = subject.config.suite.tests_to_run?
      assert_equal exp, subject.tests_to_run?

      exp = subject.config.suite.tests_to_run_count
      assert_equal exp, subject.tests_to_run_count
    end

    should "know its test/result counts" do
      exp = subject.config.suite.test_count
      assert_equal exp, subject.test_count

      exp = subject.config.suite.result_count
      assert_equal exp, subject.result_count

      exp = subject.config.suite.pass_result_count
      assert_equal exp, subject.pass_result_count

      exp = subject.config.suite.fail_result_count
      assert_equal exp, subject.fail_result_count

      exp = subject.config.suite.error_result_count
      assert_equal exp, subject.error_result_count

      exp = subject.config.suite.skip_result_count
      assert_equal exp, subject.skip_result_count

      exp = subject.config.suite.ignore_result_count
      assert_equal exp, subject.ignore_result_count
    end

    should "know if all tests are passing or not" do
      result_count = Factory.integer
      Assert.stub(subject, :result_count){ result_count }
      Assert.stub(subject, :pass_result_count){ result_count }
      assert_true subject.all_pass?

      Assert.stub(subject, :pass_result_count){ Factory.integer }
      assert_false subject.all_pass?
    end

    should "know its formatted run time, test rate and result rate" do
      format = "%.6f"

      run_time = Factory.float
      exp = format % run_time
      assert_equal exp, subject.formatted_run_time(run_time, format)
      assert_equal exp, subject.formatted_run_time(run_time)

      test_rate = Factory.float
      exp = format % test_rate
      assert_equal exp, subject.formatted_result_rate(test_rate, format)
      assert_equal exp, subject.formatted_result_rate(test_rate)

      result_rate = Factory.float
      exp = format % result_rate
      assert_equal exp, subject.formatted_result_rate(result_rate, format)
      assert_equal exp, subject.formatted_result_rate(result_rate)
    end

    should "know its formatted suite run time, test rate and result rate" do
      format = "%.6f"

      exp = format % subject.config.suite.run_time
      assert_equal exp, subject.formatted_suite_run_time(format)

      exp = format % subject.config.suite.test_rate
      assert_equal exp, subject.formatted_suite_test_rate(format)

      exp = format % subject.config.suite.result_rate
      assert_equal exp, subject.formatted_suite_result_rate(format)
    end

    should "know whether to show test profile info" do
      assert_equal !!subject.config.profile, subject.show_test_profile_info?
    end

    should "know whether to show verbose info" do
      assert_equal !!subject.config.verbose, subject.show_test_verbose_info?
    end

    should "know what result types occur in a suite's results" do
      result_types = [:pass, :fail, :ignore, :skip, :error]
      result_count = Factory.integer
      Assert.stub(subject, "#{result_types.sample}_result_count"){ result_count }

      exp = result_types.select do |type_sym|
        subject.send("#{type_sym}_result_count") > 0
      end
      assert_equal exp, subject.ocurring_result_types
    end
  end
end
