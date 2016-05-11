require 'assert'
require 'assert/test'

require 'assert/config'
require 'assert/file_line'
require 'assert/result'

class Assert::Test

  class UnitTests < Assert::Context
    desc "Assert::Test"
    setup do
      @context_class = Factory.modes_off_context_class{ desc "context class" }
      @context_info  = Factory.context_info(@context_class)
      @config        = Factory.modes_off_config
      @test_code     = proc{ assert(true) }
    end
    subject{ Assert::Test }

    should have_imeths :result_count_meth, :name_file_line_context_data
    should have_imeths :for_block, :for_method

    should "know the result count method name for a given type" do
      type = Factory.string
      exp = "#{type}_result_count".to_sym
      assert_equal exp, subject.result_count_meth(type)
    end

    should "know how to build the name and file line given context" do
      test_name = Factory.string
      data = subject.name_file_line_context_data(@context_info, test_name)

      exp = @context_info.test_name(test_name)
      assert_equal exp, data[:name]

      exp = @context_info.called_from
      assert_equal exp, data[:file_line]
    end

    should "build tests for a block" do
      name = Factory.string
      test = subject.for_block(name, @context_info, @config, &@test_code)

      exp = Assert::FileLine.parse(@context_info.called_from)
      assert_equal exp, test.file_line

      exp = @context_info.test_name(name)
      assert_equal exp, test.name

      assert_equal @context_info, test.context_info
      assert_equal @config,       test.config
      assert_equal @test_code,    test.code
    end

    should "build tests for a method" do
      meth = 'a_test_method'
      test = subject.for_method(meth, @context_info, @config)

      exp = Assert::FileLine.parse(@context_info.called_from)
      assert_equal exp, test.file_line

      exp = @context_info.test_name(meth)
      assert_equal exp, test.name

      assert_equal @context_info, test.context_info
      assert_equal @config,       test.config

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
    setup do
      @file_line = Assert::FileLine.new(Factory.string, Factory.integer.to_s)
      @meta_data = {
        :file_line => @file_line.to_s,
        :name      => Factory.string,
        :output    => Factory.string,
        :run_time  => Factory.float(1.0),
      }
      @meta_data[:total_result_count] = Factory.integer(100)
      Assert::Result.types.keys.each do |type|
        @meta_data[Assert::Test.result_count_meth(type)] = Factory.integer(100)
      end
      @run_data = {
        :context_info => @context_info,
        :config       => @config,
        :code         => @test_code
      }

      @test = Assert::Test.new(@meta_data.merge(@run_data))
    end
    subject{ @test }

    should have_readers :file_line, :name, :output, :run_time, :total_result_count
    should have_imeths *Assert::Result.types.keys.map{ |k| Assert::Test.result_count_meth(k) }
    should have_readers :context_info, :config, :code, :results
    should have_imeths :data, :context_class, :file, :line_number
    should have_imeths :result_rate, :result_count, :capture_result, :run
    should have_imeths *Assert::Result.types.keys.map{ |k| "#{k}_results" }

    should "use any given attrs" do
      assert_equal @file_line,             subject.file_line
      assert_equal @meta_data[:name],      subject.name
      assert_equal @meta_data[:output],    subject.output
      assert_equal @meta_data[:run_time],  subject.run_time

      assert_equal @meta_data[:total_result_count], subject.total_result_count

      Assert::Result.types.keys.each do |type|
        n = Assert::Test.result_count_meth(type)
        assert_equal @meta_data[n], subject.send(n)
      end

      assert_equal @context_info, subject.context_info
      assert_equal @config,       subject.config
      assert_equal @test_code,    subject.code
    end

    should "default its attrs" do
      test = Assert::Test.new

      assert_equal Assert::FileLine.parse(''), test.file_line
      assert_equal '', test.name
      assert_equal '', test.output
      assert_equal 0,  test.run_time
      assert_equal 0,  test.total_result_count

      Assert::Result.types.keys.each do |type|
        assert_equal 0, test.send(Assert::Test.result_count_meth(type))
      end

      assert_nil test.context_info
      assert_nil test.config
      assert_nil test.code
    end

    should "have no results before running" do
      assert_empty subject.results
    end

    should "know its data hash" do
      assert_equal @meta_data, subject.data
    end

    should "know its context class" do
      assert_equal @context_class, subject.context_class
    end

    should "file line and number" do
      assert_equal subject.file_line.file, subject.file
      assert_equal subject.file_line.line, subject.line_number
    end

    should "know its result rate" do
      count = Factory.integer(100)
      time  = Factory.float(1.0) + 1.0

      Assert.stub(subject, :result_count){ count }
      Assert.stub(subject, :run_time){ time }
      exp = count / time
      assert_equal exp, subject.result_rate

      Assert.stub(subject, :run_time){ 0 }
      assert_equal 0.0, subject.result_rate

      Assert.stub(subject, :run_time){ 0.0 }
      assert_equal 0.0, subject.result_rate
    end

    should "know its result counts" do
      assert_equal subject.total_result_count, subject.result_count

      Assert::Result.types.keys.each do |type|
        exp = subject.send(Assert::Test.result_count_meth(type))
        assert_equal exp, subject.result_count(type)
      end
    end

    should "capture results" do
      result           = Factory.pass_result
      prev_total_count = subject.total_result_count
      prev_pass_count  = subject.pass_result_count
      callback_result  = nil
      callback         = proc{ |r| callback_result = r}

      subject.capture_result(result, callback)

      assert_equal result,               subject.results.last
      assert_equal prev_total_count + 1, subject.total_result_count
      assert_equal prev_pass_count  + 1, subject.pass_result_count
      assert_equal result,               callback_result
    end

    should "have a custom inspect that only shows limited attributes" do
      attrs_string = [:name, :context_info, :results].collect do |method|
        "@#{method}=#{subject.send(method).inspect}"
      end.join(" ")
      expected = "#<#{subject.class}:#{'0x0%x' % (subject.object_id << 1)} #{attrs_string}>"
      assert_equal expected, subject.inspect
    end

  end

  class PassFailIgnoreTotalTests < UnitTests
    setup do
      @test = Factory.test("pass fail ignore test", @context_info) do
        ignore("something")
        assert(true)
        assert(false)
      end
      @test.context_class.setup do
        ignore("something")
        assert(true)
        assert(false)
      end
      @test.context_class.teardown do
        ignore("something")
        assert(true)
        assert(false)
      end
      @test.run
    end
    subject{ @test }

    should "know its pass results" do
      assert_kind_of Array, subject.pass_results
      assert_equal 3, subject.pass_results.size
      subject.pass_results.each do |result|
        assert_kind_of Assert::Result::Pass, result
      end
      assert_equal subject.pass_results.size, subject.result_count(:pass)
    end

    should "know its fail results" do
      assert_kind_of Array, subject.fail_results
      assert_equal 3, subject.fail_results.size
      subject.fail_results.each do |result|
        assert_kind_of Assert::Result::Fail, result
      end
      assert_equal subject.fail_results.size, subject.result_count(:fail)
    end

    should "know its ignore results" do
      assert_kind_of Array, subject.ignore_results
      assert_equal 3, subject.ignore_results.size
      subject.ignore_results.each do |result|
        assert_kind_of Assert::Result::Ignore, result
      end
      assert_equal subject.ignore_results.size, subject.result_count(:ignore)
    end

    should "know the total number of results" do
      assert_equal(9, subject.result_count)
    end

  end

  class FailHandlingTests < UnitTests
    include Assert::Test::TestHelpers

    desc "when in halt-on-fail mode"

    should "capture fail results" do
      test = Factory.test("halt-on-fail test", @context_info) do
        raise Assert::Result::TestFailure
      end
      test.run(&test_run_callback)

      assert_failed(test)
    end

    should "capture fails in the context setup" do
      test = Factory.test("setup halt-on-fail test", @context_info){ }
      test.context_class.setup{ raise Assert::Result::TestFailure }
      test.run(&test_run_callback)

      assert_failed(test)
    end

    should "capture fails in the context teardown" do
      test = Factory.test("teardown halt-on-fail test", @context_info){ }
      test.context_class.teardown{ raise Assert::Result::TestFailure }
      test.run(&test_run_callback)

      assert_failed(test)
    end

    private

    def assert_failed(test)
      with_backtrace(caller) do
        assert_equal 1, test_run_result_count, 'too many/few fail results'
        test_run_results.each do |result|
          assert_kind_of Assert::Result::Fail, result, 'not a fail result'
        end
      end
    end

  end

  class SkipHandlingTests < UnitTests
    include Assert::Test::TestHelpers

    should "capture skip results" do
      test = Factory.test("skip test", @context_info){ skip }
      test.run(&test_run_callback)

      assert_skipped(test)
    end

    should "capture skips in the context setup" do
      test = Factory.test("setup skip test", @context_info){ }
      test.context_class.setup{ skip }
      test.run(&test_run_callback)

      assert_skipped(test)
    end

    should "capture skips in the context teardown" do
      test = Factory.test("teardown skip test", @context_info){ }
      test.context_class.teardown{ skip }
      test.run(&test_run_callback)

      assert_skipped(test)
    end

    private

    def assert_skipped(test)
      with_backtrace(caller) do
        assert_equal 1, test_run_result_count, 'too many/few skip results'
        test_run_results.each do |result|
          assert_kind_of Assert::Result::Skip, result, 'not a skip result'
        end
      end
    end

  end

  class ErrorHandlingTests < UnitTests
    include Assert::Test::TestHelpers

    should "capture error results" do
      test = Factory.test("error test", @context_info) do
        raise StandardError, "WHAT"
      end
      test.run(&test_run_callback)

      assert_errored(test)
    end

    should "capture errors in the context setup" do
      test = Factory.test("setup error test", @context_info){ }
      test.context_class.setup{ raise 'an error' }
      test.run(&test_run_callback)

      assert_errored(test)
    end

    should "capture errors in the context teardown" do
      test = Factory.test("teardown error test", @context_info){ }
      test.context_class.teardown{ raise 'an error' }
      test.run(&test_run_callback)

      assert_errored(test)
    end

    private

    def assert_errored(test)
      with_backtrace(caller) do
        assert_equal 1, test_run_result_count, 'too many/few error results'
        test_run_results.each do |result|
          assert_kind_of Assert::Result::Error, result, 'not an error result'
        end
      end
    end

  end

  class SignalExceptionHandlingTests < UnitTests

    should "raise any signal exceptions and not capture as an error" do
      test = Factory.test("signal test", @context_info) do
        raise SignalException, "USR1"
      end

      assert_raises(SignalException){ test.run }
    end

    should "raises signal exceptions in the context setup" do
      test = Factory.test("setup signal test", @context_info){ }
      test.context_class.setup{ raise SignalException, 'INT' }

      assert_raises(SignalException){ test.run }
    end

    should "raises signal exceptions in the context teardown" do
      test = Factory.test("teardown signal test", @context_info){ }
      test.context_class.teardown{ raise SignalException, "TERM" }

      assert_raises(SignalException){ test.run }
    end

  end

  class ComparingTests < UnitTests
    desc "<=> another test"
    setup do
      @test = Factory.test("mmm")
    end
    subject{ @test }

    should "return 1 with a test named 'aaa' (greater than it)" do
      result = @test <=> Factory.test("aaa")
      assert_equal(1, result)
    end

    should "return 0 with a test named the same" do
      result = @test <=> Factory.test(@test.name)
      assert_equal(0, result)
    end

    should "return -1 with a test named 'zzz' (less than it)" do
      result = @test <=> Factory.test("zzz")
      assert_equal(-1, result)
    end

  end

  class CaptureOutTests < UnitTests
    desc "when capturing std out"
    setup do
      @capture_config = Assert::Config.new(:capture_output => true)
      @test = Factory.test("stdout", @capture_config) do
        puts "std out from the test"
        assert true
      end
    end

    should "capture any io from the test" do
      @test.run
      assert_equal "std out from the test\n", @test.output
    end

  end

  class FullCaptureOutTests < CaptureOutTests
    desc "across setup, teardown, and meth calls"
    setup do
      @test = Factory.test("fullstdouttest", @capture_config) do
        puts "std out from the test"
        assert a_method_an_assert_calls
      end
      @test.context_class.setup{ puts "std out from the setup" }
      @test.context_class.teardown{ puts "std out from the teardown" }
      @test.context_class.send(:define_method, "a_method_an_assert_calls") do
        puts "std out from a method an assert called"
      end
    end

    should "collect all stdout in the output accessor" do
      @test.run

      exp_out = "std out from the setup\n"\
                "std out from the test\n"\
                "std out from a method an assert called\n"\
                "std out from the teardown\n"
      assert_equal(exp_out, @test.output)
    end

  end

end
