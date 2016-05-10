require 'assert'
require 'assert/default_suite'

require 'assert/suite'

class Assert::DefaultSuite

  class UnitTests < Assert::Context
    desc "Assert::DefaultSuite"
    setup do
      @config = Factory.modes_off_config
      @suite  = Assert::DefaultSuite.new(@config)

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
      @suite.tests.each(&:run)
    end
    subject{ @suite }

    # TODO: remove once ordered methods are moved to the view
    should have_readers :tests

    should "be a Suite" do
      assert_kind_of Assert::Suite, subject
    end

    should "know its tests-to-run atts" do
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

    should "default its test/result counts" do
      assert_equal 0, subject.test_count
      assert_equal 0, subject.result_count
      assert_equal 0, subject.pass_result_count
      assert_equal 0, subject.fail_result_count
      assert_equal 0, subject.error_result_count
      assert_equal 0, subject.skip_result_count
      assert_equal 0, subject.ignore_result_count
    end

    should "increment its test count on `before_test`" do
      subject.before_test(@tests.sample)
      assert_equal 1, subject.test_count
    end

    should "increment its result counts on `on_result`" do
      subject.on_result(Factory.pass_result)
      assert_equal 1, subject.result_count
      assert_equal 1, subject.pass_result_count
      assert_equal 0, subject.fail_result_count
      assert_equal 0, subject.error_result_count
      assert_equal 0, subject.skip_result_count
      assert_equal 0, subject.ignore_result_count

      subject.on_result(Factory.fail_result)
      assert_equal 2, subject.result_count
      assert_equal 1, subject.pass_result_count
      assert_equal 1, subject.fail_result_count
      assert_equal 0, subject.error_result_count
      assert_equal 0, subject.skip_result_count
      assert_equal 0, subject.ignore_result_count

      subject.on_result(Factory.error_result)
      assert_equal 3, subject.result_count
      assert_equal 1, subject.pass_result_count
      assert_equal 1, subject.fail_result_count
      assert_equal 1, subject.error_result_count
      assert_equal 0, subject.skip_result_count
      assert_equal 0, subject.ignore_result_count

      subject.on_result(Factory.skip_result)
      assert_equal 4, subject.result_count
      assert_equal 1, subject.pass_result_count
      assert_equal 1, subject.fail_result_count
      assert_equal 1, subject.error_result_count
      assert_equal 1, subject.skip_result_count
      assert_equal 0, subject.ignore_result_count

      subject.on_result(Factory.ignore_result)
      assert_equal 5, subject.result_count
      assert_equal 1, subject.pass_result_count
      assert_equal 1, subject.fail_result_count
      assert_equal 1, subject.error_result_count
      assert_equal 1, subject.skip_result_count
      assert_equal 1, subject.ignore_result_count
    end

    should "clear the run data on `on_start`" do
      subject.before_test(@tests.sample)
      subject.on_result(Factory.pass_result)

      assert_equal 1, subject.test_count
      assert_equal 1, subject.result_count
      assert_equal 1, subject.pass_result_count

      subject.on_start

      assert_equal 0, subject.test_count
      assert_equal 0, subject.result_count
      assert_equal 0, subject.pass_result_count
    end

  end

end
