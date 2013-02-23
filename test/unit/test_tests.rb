require 'assert'
require 'assert/test'

class Assert::Test

  class BasicTests < Assert::Context
    desc "a test obj"
    setup do
      @test_code = lambda{ assert(true) }
      @context_class = Factory.context_class { desc "context class" }
      @context_info  = Factory.context_info(@context_class)
      @test = Factory.test("should do something amazing", @context_info, @test_code)
    end
    teardown do
      TEST_ASSERT_SUITE.tests.clear
    end
    subject{ @test }

    should have_readers :name, :code, :context_info
    should have_accessors :results, :output
    should have_imeths :run, :result_count, :context_class
    should have_imeths *Assert::Result.types.keys.collect{ |k| "#{k}_results" }

    should "build its name from the context description" do
      exp_name = "context class should do something amazing"
      assert_equal exp_name, subject.name
    end

    should "know it's context class and code" do
      assert_equal @context_class, subject.context_class
      assert_equal @test_code, subject.code
    end

    should "have zero results before running" do
      assert_equal 0, subject.result_count
    end

    should "have a custom inspect that only shows limited attributes" do
      attrs_string = [:name, :context_info, :results].collect do |method|
        "@#{method}=#{subject.send(method).inspect}"
      end.join(" ")
      expected = "#<#{subject.class} #{attrs_string}>"
      assert_equal expected, subject.inspect
    end

  end

  class PassFailIgnoreTotalTests < BasicTests
    setup do
      @test = Factory.test("pass fail ignore test", @context_info) do
        ignore("something")
        assert(true)
        assert(false)
        ignore("something else")
        assert(34)
        assert(nil)
      end
      @test.run
    end
    subject{ @test }

    should "know its pass results" do
      assert_kind_of Array, subject.pass_results
      assert_equal 2, subject.pass_results.size
      subject.pass_results.each do |result|
        assert_kind_of Assert::Result::Pass, result
      end
      assert_equal subject.pass_results.size, subject.result_count(:pass)
    end

    should "know its fail results" do
      assert_kind_of Array, subject.fail_results
      assert_equal 2, subject.fail_results.size
      subject.fail_results.each do |result|
        assert_kind_of Assert::Result::Fail, result
      end
      assert_equal subject.fail_results.size, subject.result_count(:fail)
    end

    should "know its ignore results" do
      assert_kind_of Array, subject.ignore_results
      assert_equal 2, subject.ignore_results.size
      subject.ignore_results.each do |result|
        assert_kind_of Assert::Result::Ignore, result
      end
      assert_equal subject.ignore_results.size, subject.result_count(:ignore)
    end

    should "know the total number of results" do
      assert_equal(6, subject.result_count)
    end

  end

  class SkipHandlingTests < BasicTests
    setup do
      @test = Factory.test("skip test", @context_info) { skip }
      @test.run
    end
    subject{ @test }

    should "know its skip results" do
      assert_kind_of Array, subject.skip_results
      assert_equal 1, subject.skip_results.size
      subject.skip_results.each do |result|
        assert_kind_of Assert::Result::Skip, result
      end
      assert_equal subject.skip_results.size, subject.result_count(:skip)
    end

  end

  class ErrorHandlingTests < BasicTests
    setup do
      @test = Factory.test("error test", @context_info) do
        raise StandardError, "WHAT"
      end
      @test.run
    end
    subject{ @test }

    should "know its error results" do
      assert_kind_of Array, subject.error_results
      assert_equal 1, subject.error_results.size
      subject.error_results.each do |result|
        assert_kind_of Assert::Result::Error, result
      end
      assert_equal subject.error_results.size, subject.result_count(:error)
    end

  end

  class ComparingTests < BasicTests
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

  class CaptureOutTests < BasicTests
    desc "when capturing std out"
    setup do
      @test = Factory.test("stdout") {
        puts "std out from the test"
        assert true
      }
      @orig_show = Assert.config.show_output
      Assert.config.show_output false
    end
    teardown do
      Assert.config.show_output @orig_show
    end

    should "capture any io from the test" do
      @test.run
      assert_equal "std out from the test\n", @test.output
    end

  end

  class FullCaptureOutTests < CaptureOutTests
    desc "across setup, teardown, and meth calls"
    setup do
      @test = Factory.test("fullstdouttest") do
        puts "std out from the test"
        assert a_method_an_assert_calls
      end
      @test.context_class.setup { puts "std out from the setup" }
      @test.context_class.teardown { puts "std out from the teardown" }
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