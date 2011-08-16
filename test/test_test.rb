require 'assert'

class Assert::Test

  class BasicTest < Assert::Context
    desc "Assert test"
    setup do
      test_name = "test: should do something amazing"
      @test_code = lambda{ assert(true) }
      context_desc = "context class"
      @context_class = Factory.context_class do
        desc context_desc
      end
      @test = Factory.test(test_name, @context_class, @test_code)
      @expected_name = [ context_desc, test_name.gsub(/^test:\s+should/, "should") ].join(" ")
    end
    teardown do
      TEST_ASSERT_SUITE.clear
    end
    subject{ @test }

    should have_readers :name, :code, :context_class
    should have_accessor :results
    should have_instance_methods :run, :result_count
    should have_instance_methods *Assert::Result.types.keys.collect{|k| "#{k}_results".to_sym }

    should "set it's test name to the context description with the passed in name cleaned" do
      assert_equal @expected_name, subject.name
    end

    should "set it's context class and code from its initialize" do
      assert_equal @context_class, subject.context_class
      assert_equal @test_code, subject.code
    end

    should "have zero results before running" do
      assert_equal 0, subject.result_count
    end

    should "have a custom inspect that only shows limited attributes" do
      attributes_string = [ :name, :context_class, :results ].collect do |method|
        "@#{method}=#{subject.send(method).inspect}"
      end.join(" ")
      expected = "#<#{subject.class} #{attributes_string}>"
      assert_equal expected, subject.inspect
    end

  end


  # testing <type>_results methods and result_count(<type>)
  class ResultsTest < BasicTest
    desc "methods from Assert::Result.types"
  end

  class PassFailIgnoreTest < ResultsTest
    setup do
      @test = Factory.test("pass fail ignore test", @context_class) do
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

    should "return the pass results with #pass_results" do
      assert_kind_of Array, subject.pass_results
      assert_equal 2, subject.pass_results.size
      subject.pass_results.each do |result|
        assert_kind_of Assert::Result::Pass, result
      end
    end

    should "return the size of #pass_results with #result_count(:pass)" do
      assert_equal(subject.pass_results.size, subject.result_count(:pass))
    end

    should "return the fail results with #fail_results" do
      assert_kind_of Array, subject.fail_results
      assert_equal 2, subject.fail_results.size
      subject.fail_results.each do |result|
        assert_kind_of Assert::Result::Fail, result
      end
    end

    should "return the size of #fail_results with #result_count(:fail)" do
      assert_equal(subject.fail_results.size, subject.result_count(:fail))
    end

    should "return the ignore results with #ignore_results" do
      assert_kind_of Array, subject.ignore_results
      assert_equal 2, subject.ignore_results.size
      subject.ignore_results.each do |result|
        assert_kind_of Assert::Result::Ignore, result
      end
    end

    should "return the size of #ignore_results with #result_count(:ignore)" do
      assert_equal(subject.ignore_results.size, subject.result_count(:ignore))
    end

    should "return the total number of tests with #result_count" do
      assert_equal(6, subject.result_count)
    end

  end



  class SkipHandlingTest < ResultsTest
    setup do
      @test = Factory.test("skip test", @context_class) { skip }
      @test.run
    end
    subject{ @test }

    should "return the skip results with #skip_results" do
      assert_kind_of Array, subject.skip_results
      assert_equal 1, subject.skip_results.size
      subject.skip_results.each do |result|
        assert_kind_of Assert::Result::Skip, result
      end
    end

    should "return the size of #skip_results with #result_count(:skip)" do
      assert_equal(subject.skip_results.size, subject.result_count(:skip))
    end

  end



  class ErrorHandlingTest < ResultsTest
    setup do
      @test = Factory.test("error test", @context_class) do
        raise StandardError, "WHAT"
      end
      @test.run
    end
    subject{ @test }

    should "return the error results with #error_results" do
      assert_kind_of Array, subject.error_results
      assert_equal 1, subject.error_results.size
      subject.error_results.each do |result|
        assert_kind_of Assert::Result::Error, result
      end
    end

    should "return the size of #error_results with #result_count(:error)" do
      assert_equal(subject.error_results.size, subject.result_count(:error))
    end

  end



  class ComparingTest < BasicTest
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

end
