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
          @config ||= [Assert.config, Assert::Config.new].choice
        end
      end
      @helpers = @helpers_class.new
    end
    subject{ @helpers }

    should have_imeths :runner_seed, :count, :tests?, :all_pass?
    should have_imeths :run_time, :test_rate, :result_rate
    should have_imeths :suite_contexts, :ordered_suite_contexts
    should have_imeths :suite_files, :ordered_suite_files
    should have_imeths :show_test_profile_info?, :show_test_verbose_info?

    should "know its runner seed" do
      assert_equal subject.config.runner_seed, subject.runner_seed
    end

    should "know how to count things on the suite" do
      thing = [:pass, :fail, :results, :tests].choice
      assert_equal subject.config.suite.count(thing), subject.count(thing)
    end

    should "know if it has tests or not" do
      exp = subject.count(:tests) > 0
      assert_equal exp, subject.tests?
    end

    should "know its formatted run time, test rate and result rate" do
      format = '%.6f'

      exp = format % subject.config.suite.run_time
      assert_equal exp, subject.run_time(format)

      exp = format % subject.config.suite.test_rate
      assert_equal exp, subject.test_rate(format)

      exp = format % subject.config.suite.result_rate
      assert_equal exp, subject.result_rate(format)
    end

    should "know its suite contexts and ordered suite contexts" do
      exp = subject.config.suite.tests.inject([]) do |contexts, test|
        contexts << test.context_info.klass
      end.uniq
      assert_equal exp, subject.suite_contexts

      exp = subject.suite_contexts.sort{ |a,b| a.to_s <=> b.to_s }
      assert_equal exp, subject.ordered_suite_contexts
    end

    should "know its suite files and ordered suite files" do
      exp = subject.config.suite.tests.inject([]) do |files, test|
        files << test.context_info.file
      end.uniq
      assert_equal exp, subject.suite_files

      exp = subject.suite_files.sort{ |a,b| a.to_s <=> b.to_s }
      assert_equal exp, subject.ordered_suite_files
    end

    should "know whether to show test profile info" do
      assert_equal !!subject.config.profile, subject.show_test_profile_info?
    end

    should "know whether to show verbose info" do
      assert_equal !!subject.config.verbose, subject.show_test_verbose_info?
    end

  end

end
