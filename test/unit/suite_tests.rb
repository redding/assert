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

  class InitTests < UnitTests
    desc "when init"
    setup do
      @config = Factory.modes_off_config
      @suite  = Assert::Suite.new(@config)
    end
    subject{ @suite }

    should have_readers :config, :test_methods, :setups, :teardowns
    should have_accessors :start_time, :end_time
    should have_imeths :suite, :setup, :startup, :teardown, :shutdown
    should have_imeths :tests_to_run?, :tests_to_run_count, :clear_tests_to_run
    should have_imeths :find_test_to_run, :sorted_tests_to_run
    should have_imeths :run_time, :test_rate, :result_rate
    should have_imeths :test_count, :result_count, :pass_result_count
    should have_imeths :fail_result_count, :error_result_count
    should have_imeths :skip_result_count, :ignore_result_count
    should have_imeths :before_load, :on_test, :after_load
    should have_imeths :on_start, :on_finish, :on_interrupt
    should have_imeths :before_test, :after_test, :on_result

    should "know its config" do
      assert_equal @config, subject.config
    end

    should "default its attrs" do
      assert_equal [], subject.test_methods
      assert_equal [], subject.setups
      assert_equal [], subject.teardowns

      assert_equal subject.start_time, subject.end_time
    end

    should "override the config helper's suite value with itself" do
      assert_equal subject, subject.suite
    end

    should "not provide any test/result count implementations" do
      assert_nil subject.test_count
      assert_nil subject.pass_result_count
      assert_nil subject.fail_result_count
      assert_nil subject.error_result_count
      assert_nil subject.skip_result_count
      assert_nil subject.ignore_result_count
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

  class WithTestsLoadedTests < InitTests
    desc "with tests loaded"
    setup do
      ci = proc{ Factory.context_info(Factory.modes_off_context_class) }
      @tests = [
        Factory.test("should nothing", ci.call){ },
        Factory.test("should pass",    ci.call){ assert(1==1); refute(1==0) },
        Factory.test("should fail",    ci.call){ ignore; assert(1==0); refute(1==1) },
        Factory.test("should ignore",  ci.call){ ignore },
        Factory.test("should skip",    ci.call){ skip; ignore; assert(1==1) },
        Factory.test("should error",   ci.call){ raise Exception; ignore; assert(1==1) }
      ]
      @tests.each{ |test| @suite.on_test(test) }
    end

    should "know its tests-to-run attrs" do
      assert_equal @tests.size, subject.tests_to_run_count
      assert_true subject.tests_to_run?

      subject.clear_tests_to_run

      assert_equal 0, subject.tests_to_run_count
      assert_false subject.tests_to_run?
    end

    should "find a test to run given a file line" do
      test = @tests.sample
      assert_same test, subject.find_test_to_run(test.file_line)
    end

    should "know its sorted tests to run" do
      sorted_tests = subject.sorted_tests_to_run{ 1 }
      assert_equal @tests.size, sorted_tests.size
      assert_kind_of Assert::Test, sorted_tests.first
      assert_same sorted_tests.first, subject.sorted_tests_to_run{ 1 }.first
    end

  end

end
