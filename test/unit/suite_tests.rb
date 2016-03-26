require 'assert'
require 'assert/suite'

require 'assert/config_helpers'
require 'assert/test'
require 'test/support/inherited_stuff'

class Assert::Suite

  class UnitTests < Assert::Context
    desc "Assert::Suite"
    subject{ Assert::Suite }

    should "include the config helpers" do
      assert_includes Assert::ConfigHelpers, subject
    end

    should "know its test method regex" do
      assert_match     "test#{Factory.string}", subject::TEST_METHOD_REGEX
      assert_not_match "#{Factory.string}test", subject::TEST_METHOD_REGEX
    end

  end

  class InitTests < Assert::Context
    desc "when init"
    setup do
      @config = Factory.modes_off_config
      @suite  = Assert::Suite.new(@config)
    end
    subject{ @suite }

    should have_readers :config, :tests, :test_methods
    should have_accessors :start_time, :end_time
    should have_imeths :suite, :setup, :startup, :teardown, :shutdown
    should have_imeths :run_time, :test_rate, :result_rate, :count
    should have_imeths :ordered_tests, :reversed_tests
    should have_imeths :ordered_tests_by_run_time, :reversed_tests_by_run_time
    should have_imeths :test_count
    should have_imeths :ordered_results, :reversed_results
    should have_imeths :ordered_results_for_dump, :reversed_results_for_dump
    should have_imeths :result_count
    should have_imeths :before_load, :after_load
    should have_imeths :on_start, :on_finish, :on_interrupt
    should have_imeths :before_test, :after_test, :on_result

    should "know its config" do
      assert_equal @config, subject.config
    end

    should "override the config helper's suite value with itself" do
      assert_equal subject, subject.suite
    end

    should "default its attrs" do
      assert_equal [], subject.tests
      assert_equal [], subject.test_methods
      assert_equal [], subject.setups
      assert_equal [], subject.teardowns

      assert_equal subject.start_time, subject.end_time
    end

    should "know its run time and rates" do
      assert_equal 0, subject.run_time
      assert_equal 0, subject.test_rate
      assert_equal 0, subject.result_rate

      time = Factory.integer(3).to_f
      subject.end_time = subject.start_time + time
      count = Factory.integer(10)
      Assert.stub(subject, :test_count){ count }
      Assert.stub(subject, :result_count){ count }

      assert_equal time, subject.run_time
      assert_equal (subject.test_count / subject.run_time),   subject.test_rate
      assert_equal (subject.result_count / subject.run_time), subject.result_rate
    end

    should "not provide any test or result attrs" do
      assert_nil subject.ordered_tests
      assert_nil subject.reversed_tests
      assert_nil subject.ordered_tests_by_run_time
      assert_nil subject.reversed_tests_by_run_time
      assert_nil subject.test_count

      assert_nil subject.ordered_results
      assert_nil subject.reversed_results
      assert_nil subject.ordered_results_for_dump
      assert_nil subject.reversed_results_for_dump
      assert_nil subject.result_count
    end

    should "add setup procs" do
      status = nil
      @suite.setup{ status = "setups" }
      @suite.startup{ status += " have been run" }

      assert_equal 2, subject.setups.count
      subject.setups.each(&:call)
      assert_equal "setups have been run", status
    end

    should "add teardown procs" do
      status = nil
      @suite.teardown{ status = "teardowns" }
      @suite.shutdown{ status += " have been run" }

      assert_equal 2, subject.teardowns.count
      subject.teardowns.each(&:call)
      assert_equal "teardowns have been run", status
    end

  end

end
