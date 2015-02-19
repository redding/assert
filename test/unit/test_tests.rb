require 'assert'
require 'assert/test'

require 'assert/config'
require 'assert/file_line'

class Assert::Test

  class UnitTests < Assert::Context
    desc "Assert::Test"
    setup do
      @test_code = lambda{ assert(true) }
      @context_class = Factory.modes_off_context_class{ desc "context class" }
      @context_info  = Factory.context_info(@context_class)
      @test = Factory.test("should do something amazing", @context_info, :code => @test_code)
    end
    subject{ @test }

    should have_readers :context_info, :config
    should have_readers :name, :file_line, :code
    should have_accessors :results, :output, :run_time
    should have_imeths :context_class, :file, :line_number
    should have_imeths :run, :result_count, :result_rate
    should have_imeths *Assert::Result.types.keys.collect{ |k| "#{k}_results" }

    should "know its context class" do
      assert_equal @context_class, subject.context_class
    end

    should "know its config" do
      cust_config = Assert::Config.new
      assert_equal cust_config, Factory.test(cust_config).config
    end

    should "know its name, file line, file and number" do
      exp = "context class should do something amazing"
      assert_equal exp, subject.name

      exp = Assert::FileLine.new(*@context_info.called_from.split(':'))
      assert_equal exp, subject.file_line

      assert_equal subject.file_line.file, subject.file
      assert_equal subject.file_line.line, subject.line_number
    end

    should "get its code from any passed opt, falling back on any given block" do
      assert_equal @test_code, subject.code

      given_block = Proc.new{ assert(false) }
      assert_equal given_block, Factory.test(&given_block).code

      assert_kind_of Proc, Factory.test.code
    end

    should "have zero results before running" do
      assert_equal 0, subject.result_count
    end

    should "have a zero run time and result rate by default" do
      assert_equal 0, subject.run_time
      assert_equal 0, subject.result_rate
    end

    should "have a non-zero run time and result rate after it is run" do
      subject.run
      assert_not_equal 0, subject.run_time
      assert_not_equal 0, subject.result_rate
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

  class SkipHandlingTests < UnitTests
    setup do
      @test = Factory.test("skip test", @context_info){ skip }
      @test.run
    end
    subject{ @test }

    should "capture skip results" do
      assert_skipped(subject)
    end

    should "capture skips in the context setup" do
      test = Factory.test("setup skip test", @context_info){ }
      test.context_class.setup{ skip }
      test.run

      assert_skipped(test)
    end

    should "capture skips in the context teardown" do
      test = Factory.test("teardown skip test", @context_info){ }
      test.context_class.teardown{ skip }
      test.run

      assert_skipped(test)
    end

    private

    def assert_skipped(test)
      with_backtrace(caller) do
        assert_equal 1, test.skip_results.size, 'too many/few skip results'
        test.skip_results.each do |result|
          assert_kind_of Assert::Result::Skip, result, 'result is not a skip result'
        end
        assert_equal test.skip_results.size, test.result_count(:skip), 'skip result not counted'
      end
    end

  end

  class ErrorHandlingTests < UnitTests
    setup do
      @test = Factory.test("error test", @context_info) do
        raise StandardError, "WHAT"
      end
      @test.run
    end
    subject{ @test }

    should "capture error results" do
      assert_errored(subject)
    end

    should "capture errors in the context setup" do
      test = Factory.test("setup error test", @context_info){ }
      test.context_class.setup{ raise 'an error' }
      test.run

      assert_errored(test)
    end

    should "capture errors in the context teardown" do
      test = Factory.test("teardown error test", @context_info){ }
      test.context_class.teardown{ raise 'an error' }
      test.run

      assert_errored(test)
    end

    private

    def assert_errored(test)
      with_backtrace(caller) do
        assert_equal 1, subject.error_results.size, 'too many/few error results'
        test.error_results.each do |result|
          assert_kind_of Assert::Result::Error, result, 'result is not an error result'
        end
        assert_equal test.error_results.size, test.result_count(:error), 'error result not counted'
      end
    end

  end

  class SignalExceptionHandlingTests < UnitTests
    setup do
      @test = Factory.test("signal test", @context_info) do
        raise SignalException, "USR1"
      end
    end
    subject{ @test }

    should "raise any signal exceptions and not capture as an error" do
      assert_raises(SignalException){ subject.run }
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
