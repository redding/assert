require "assert"
require "assert/test"

require "assert/config"
require "assert/file_line"
require "assert/result"

class Assert::Test
  class UnitTests < Assert::Context
    desc "Assert::Test"
    subject { Assert::Test }

    let(:context_class1) { Factory.modes_off_context_class { desc "context class" } }
    let(:context_info1)  { Factory.context_info(context_class1) }
    let(:config1)        { Factory.modes_off_config }
    let(:test_code1)     { proc { assert(true) } }

    should have_imeths :name_file_line_context_data, :for_block, :for_method

    should "know how to build the name and file line given context" do
      test_name = Factory.string
      data = subject.name_file_line_context_data(context_info1, test_name)

      exp = context_info1.test_name(test_name)
      assert_equal exp, data[:name]

      exp = context_info1.called_from
      assert_equal exp, data[:file_line]
    end

    should "build tests for a block" do
      name = Factory.string
      test = subject.for_block(name, context_info1, config1, &test_code1)

      exp = Assert::FileLine.parse(context_info1.called_from)
      assert_equal exp, test.file_line

      exp = context_info1.test_name(name)
      assert_equal exp, test.name

      assert_equal context_info1, test.context_info
      assert_equal config1,       test.config
      assert_equal test_code1,    test.code
    end

    should "build tests for a method" do
      meth = "a_test_method"
      test = subject.for_method(meth, context_info1, config1)

      exp = Assert::FileLine.parse(context_info1.called_from)
      assert_equal exp, test.file_line

      exp = context_info1.test_name(meth)
      assert_equal exp, test.name

      assert_equal context_info1, test.context_info
      assert_equal config1,       test.config

      assert_kind_of Proc, test.code
      self.instance_eval(&test.code)
      assert_true @a_test_method_called
    end

    def a_test_method
      @a_test_method_called = true
    end
  end

  class InitWithDataTests < UnitTests
    desc "when init with data"
    subject { test1 }

    let(:file_line1) { Assert::FileLine.new(Factory.string, Factory.integer.to_s) }
    let(:meta_data1) {
      {
        :file_line => file_line1.to_s,
        :name      => Factory.string,
        :output    => Factory.string,
        :run_time  => Factory.float(1.0),
      }
    }
    let(:run_data1) {
      {
        :context_info => context_info1,
        :config       => config1,
        :code         => test_code1
      }
    }
    let(:test1) { Assert::Test.new(meta_data1.merge(run_data1)) }

    should have_imeths :file_line, :file_name, :line_num
    should have_imeths :name, :output, :run_time
    should have_imeths :context_info, :context_class, :config, :code, :run

    should "use any given attrs" do
      assert_equal file_line1,             subject.file_line
      assert_equal meta_data1[:name],      subject.name
      assert_equal meta_data1[:output],    subject.output
      assert_equal meta_data1[:run_time],  subject.run_time

      assert_equal context_info1, subject.context_info
      assert_equal config1,       subject.config
      assert_equal test_code1,    subject.code
    end

    should "default its attrs" do
      test = Assert::Test.new

      assert_equal Assert::FileLine.parse(""), test.file_line
      assert_equal "", test.name
      assert_equal "", test.output
      assert_equal 0,  test.run_time

      assert_nil test.context_info
      assert_nil test.config
      assert_nil test.code
    end

    should "know its context class" do
      assert_equal context_class1, subject.context_class
    end

    should "know its file line attrs" do
      assert_equal subject.file_line.file,      subject.file_name
      assert_equal subject.file_line.line.to_i, subject.line_num
    end

    should "have a custom inspect that only shows limited attributes" do
      attrs = [:name, :context_info].collect do |method|
        "@#{method}=#{subject.send(method).inspect}"
      end.join(" ")
      exp = "#<#{subject.class}:#{"0x0%x" % (subject.object_id << 1)} #{attrs}>"
      assert_equal exp, subject.inspect
    end
  end

  class PassFailIgnoreHandlingTests < UnitTests
    include Assert::Test::TestHelpers

    subject { test1 }

    setup do
      subject.context_class.setup do
        ignore("something")
        assert(true)
        assert(false)
      end
      subject.context_class.teardown do
        ignore("something")
        assert(true)
        assert(false)
      end
      subject.run(&test_run_callback)
    end

    let(:test1) {
      Factory.test("pass fail ignore test", context_info1) do
        ignore("something")
        assert(true)
        assert(false)
      end
    }

    should "capture results in the test and any setups/teardowns" do
      assert_equal 9, test_run_results.size
      test_run_results.each do |result|
        assert_kind_of Assert::Result::Base, result
      end
    end

    should "capture pass results in the test and any setups/teardowns" do
      assert_equal 3, test_run_results(:pass).size
      test_run_results(:pass).each do |result|
        assert_kind_of Assert::Result::Pass, result
      end
    end

    should "capture fail results in the test and any setups/teardowns" do
      assert_equal 3, test_run_results(:fail).size
      test_run_results(:fail).each do |result|
        assert_kind_of Assert::Result::Fail, result
      end
    end

    should "capture ignore results in the test and any setups/teardowns" do
      assert_equal 3, test_run_results(:ignore).size
      test_run_results(:ignore).each do |result|
        assert_kind_of Assert::Result::Ignore, result
      end
    end
  end

  class FailHandlingTests < UnitTests
    include Assert::Test::TestHelpers

    desc "when in halt-on-fail mode"

    should "capture fail results" do
      test = Factory.test("halt-on-fail test", context_info1) do
        raise Assert::Result::TestFailure
      end
      test.run(&test_run_callback)

      assert_failed(test)
    end

    should "capture fails in the context setup" do
      test = Factory.test("setup halt-on-fail test", context_info1){ }
      test.context_class.setup{ raise Assert::Result::TestFailure }
      test.run(&test_run_callback)

      assert_failed(test)
    end

    should "capture fails in the context teardown" do
      test = Factory.test("teardown halt-on-fail test", context_info1){ }
      test.context_class.teardown{ raise Assert::Result::TestFailure }
      test.run(&test_run_callback)

      assert_failed(test)
    end

    private

    def assert_failed(test)
      with_backtrace(caller) do
        assert_equal 1, test_run_result_count, "too many/few fail results"
        test_run_results.each do |result|
          assert_kind_of Assert::Result::Fail, result, "not a fail result"
        end
      end
    end
  end

  class SkipHandlingTests < UnitTests
    include Assert::Test::TestHelpers

    should "capture skip results" do
      test = Factory.test("skip test", context_info1){ skip }
      test.run(&test_run_callback)

      assert_skipped(test)
    end

    should "capture skips in the context setup" do
      test = Factory.test("setup skip test", context_info1){ }
      test.context_class.setup{ skip }
      test.run(&test_run_callback)

      assert_skipped(test)
    end

    should "capture skips in the context teardown" do
      test = Factory.test("teardown skip test", context_info1){ }
      test.context_class.teardown{ skip }
      test.run(&test_run_callback)

      assert_skipped(test)
    end

    private

    def assert_skipped(test)
      with_backtrace(caller) do
        assert_equal 1, test_run_result_count, "too many/few skip results"
        test_run_results.each do |result|
          assert_kind_of Assert::Result::Skip, result, "not a skip result"
        end
      end
    end
  end

  class ErrorHandlingTests < UnitTests
    include Assert::Test::TestHelpers

    should "capture error results" do
      test = Factory.test("error test", context_info1) do
        raise StandardError, "WHAT"
      end
      test.run(&test_run_callback)

      assert_errored(test)
    end

    should "capture errors in the context setup" do
      test = Factory.test("setup error test", context_info1){ }
      test.context_class.setup{ raise "an error" }
      test.run(&test_run_callback)

      assert_errored(test)
    end

    should "capture errors in the context teardown" do
      test = Factory.test("teardown error test", context_info1){ }
      test.context_class.teardown{ raise "an error" }
      test.run(&test_run_callback)

      assert_errored(test)
    end

    private

    def assert_errored(test)
      with_backtrace(caller) do
        assert_equal 1, test_run_result_count, "too many/few error results"
        test_run_results.each do |result|
          assert_kind_of Assert::Result::Error, result, "not an error result"
        end
      end
    end
  end

  class SignalExceptionHandlingTests < UnitTests
    should "raise any signal exceptions and not capture as an error" do
      test = Factory.test("signal test", context_info1) do
        raise SignalException, "USR1"
      end

      assert_raises(SignalException){ test.run }
    end

    should "raises signal exceptions in the context setup" do
      test = Factory.test("setup signal test", context_info1){ }
      test.context_class.setup{ raise SignalException, "INT" }

      assert_raises(SignalException){ test.run }
    end

    should "raises signal exceptions in the context teardown" do
      test = Factory.test("teardown signal test", context_info1){ }
      test.context_class.teardown{ raise SignalException, "TERM" }

      assert_raises(SignalException){ test.run }
    end
  end

  class ComparingTests < UnitTests
    desc "<=> another test"
    subject { test1 }

    let(:test1) { Factory.test("mmm") }

    should "return 1 with a test named 'aaa' (greater than it)" do
      result = test1 <=> Factory.test("aaa")
      assert_equal(1, result)
    end

    should "return 0 with a test named the same" do
      result = test1 <=> Factory.test(test1.name)
      assert_equal(0, result)
    end

    should "return -1 with a test named 'zzz' (less than it)" do
      result = test1 <=> Factory.test("zzz")
      assert_equal(-1, result)
    end
  end

  class CaptureOutTests < UnitTests
    desc "when capturing std out"

    let(:capture_config1) { Assert::Config.new(:capture_output => true) }
    let(:test1) {
      Factory.test("stdout", capture_config1) do
        puts "std out from the test"
        assert true
      end
    }

    should "capture any io from the test" do
      test1.run
      assert_equal "std out from the test\n", test1.output
    end
  end

  class FullCaptureOutTests < CaptureOutTests
    desc "across setup, teardown, and meth calls"

    setup do
      test1.context_class.setup{ puts "std out from the setup" }
      test1.context_class.teardown{ puts "std out from the teardown" }
      test1.context_class.send(:define_method, "a_method_an_assert_calls") do
        puts "std out from a method an assert called"
      end
    end

    let(:test1) {
      Factory.test("fullstdouttest", capture_config1) do
        puts "std out from the test"
        assert a_method_an_assert_calls
      end
    }

    should "collect all stdout in the output accessor" do
      test1.run

      exp_out =
        "std out from the setup\n"\
        "std out from the test\n"\
        "std out from a method an assert called\n"\
        "std out from the teardown\n"
      assert_equal(exp_out, test1.output)
    end
  end
end
