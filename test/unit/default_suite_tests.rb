require "assert"
require "assert/default_suite"

require "assert/suite"

class Assert::DefaultSuite
  class UnitTests < Assert::Context
    desc "Assert::DefaultSuite"
    setup do
      ci = Factory.context_info(Factory.modes_off_context_class)
      @test = Factory.test(Factory.string, ci){ }

      @config = Factory.modes_off_config
      @suite  = Assert::DefaultSuite.new(@config)
    end
    subject{ @suite }

    should "be a Suite" do
      assert_kind_of Assert::Suite, subject
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
      subject.before_test(@test)
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
      subject.before_test(@test)
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
