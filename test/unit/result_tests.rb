require 'assert'
require 'assert/result'

module Assert::Result

  class BacktraceTests < Assert::Context
    desc "a result backtrace"
    setup do
      @backtrace = Backtrace.new(caller)
    end
    subject { @backtrace }

    should have_instance_methods :to_s, :filtered

    should "be an Array" do
      assert_kind_of ::Array, subject
    end

    should "render as a string by joining on the newline" do
      assert_equal subject.join("\n"), subject.to_s
    end

    should "another backtrace when filtered" do
      assert_kind_of Backtrace, subject
    end

    should "default itself when created from nil" do
      assert_equal ["No backtrace"], Backtrace.new
    end

  end

  class BaseTests < Assert::Context
    desc "a base result"
    setup do
      @test = Factory.test("a test name")
      @result = Assert::Result::Base.new(@test, "a message", ["line 1", "line2"])
    end
    subject{ @result }

    should have_readers :test, :message, :backtrace
    should have_imeths :test_name, :name, :to_sym, :to_s, :trace

    Assert::Result.types.keys.each do |type|
      should "respond to the instance method ##{type}?" do
        assert_respond_to "#{type}?", subject
      end

      should "not be #{type}" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "know its test" do
      assert_equal @test, subject.test
    end

    should "nil out empty messages" do
      assert_equal nil, Assert::Result::Base.new(@test, "").message
    end

    should "show only its class and message when inspected" do
      exp = "#<#{subject.class} @message=#{subject.message.inspect}>"
      assert_equal exp, subject.inspect
    end

  end

  class ToStringTests < BaseTests

    should "include its test context name in the to_s" do
      assert subject.to_s.include?(subject.test_name)
    end

    should "include its test name in the to_s" do
      assert subject.to_s.include?(subject.test_name)
    end

    should "include its message in the to_s" do
      assert subject.to_s.include?(subject.message)
    end

    should "include its trace in the to_s" do
      assert subject.to_s.include?(subject.trace)
    end

    should "have a trace with the first filtered line of the backtrace" do
      assert_equal subject.backtrace.filtered.first, subject.trace
    end
  end

  class PassTests < Assert::Context
    desc "a pass result"
    setup do
      @test = Factory.test("a test name")
      @result = Assert::Result::Pass.new(@test, "passed", [])
    end
    subject { @result }

    should "be pass?" do
      assert_equal true, subject.pass?
    end

    Assert::Result.types.keys.reject{|k| k == :pass}.each do |type|
      should "not be #{type}?" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "know its to_sym" do
      assert_equal :pass, subject.to_sym
    end

    should "know its name" do
      assert_equal "Pass", subject.name
    end

    should "include PASS in its to_s" do
      assert subject.to_s.include?("PASS")
    end

  end

  class IgnoreTests < Assert::Context
    desc "an ignore result"
    setup do
      @test = Factory.test("a test name")
      @result = Assert::Result::Ignore.new(@test, "ignored", [])
    end
    subject { @result }

    should "be ignore?" do
      assert_equal true, subject.ignore?
    end

    Assert::Result.types.keys.reject{|k| k == :ignore}.each do |type|
      should "not be #{type}?" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "know its to_sym" do
      assert_equal :ignore, subject.to_sym
    end

    should "know its name" do
      assert_equal "Ignore", subject.name
    end

    should "include IGNORE in its to_s" do
      assert subject.to_s.include?("IGNORE")
    end

  end

  class FailTests < Assert::Context
    desc "a fail result"
    setup do
      @test = Factory.test("a test name")
      @result = Assert::Result::Fail.new(@test, "failed", [])
    end
    subject { @result }

    should "use a runtime error (TestFailure) for controlling flow" do
      assert_kind_of RuntimeError, Assert::Result::TestFailure.new
    end

    should "be fail?" do
      assert_equal true, subject.fail?
    end

    Assert::Result.types.keys.reject{|k| k == :fail}.each do |type|
      should "not be #{type}?" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "know its to_sym" do
      assert_equal :fail, subject.to_sym
    end

    should "know its name" do
      assert_equal "Fail", subject.name
    end

    should "include FAIL in its to_s" do
      assert subject.to_s.include?("FAIL")
    end

  end

  class SkipTests < Assert::Context
    desc "a skip result"
    setup do
      @test = Factory.test("a test name")
      @exception = nil
      begin
        raise TestSkipped, "test ski["
      rescue Exception => err
        @exception = err
      end
      @result = Assert::Result::Skip.new(@test, @exception)
    end
    subject { @result }

    should "use a runtime error (TestSkipped) for controlling flow" do
      assert_kind_of RuntimeError, Assert::Result::TestSkipped.new
    end

    should "be skip?" do
      assert_equal true, subject.skip?
    end

    Assert::Result.types.keys.reject{|k| k == :skip}.each do |type|
      should "not be #{type}?" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "know its to_sym" do
      assert_equal :skip, subject.to_sym
    end

    should "know its name" do
      assert_equal "Skip", subject.name
    end

    should "include SKIP in its to_s" do
      assert subject.to_s.include?("SKIP")
    end

  end

  class ErrorTests < Assert::Context
    desc "an error result"
    setup do
      @test = Factory.test("a test name")
      @exception = nil
      begin
        raise Exception, "test error"
      rescue Exception => err
        @exception = err
      end
      @result = Assert::Result::Error.new(@test, @exception)
    end
    subject { @result }

    should "be error?" do
      assert_equal true, subject.error?
    end

    Assert::Result.types.keys.reject{|k| k == :error}.each do |type|
      should "not be #{type}?" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "know its to_sym" do
      assert_equal :error, subject.to_sym
    end

    should "know its name" do
      assert_equal "Error", subject.name
    end

    should "include ERRORED in its to_s" do
      assert subject.to_s.include?("ERROR")
    end

    should "have a trace created from the original exception's unfiltered backtrace" do
      assert_equal @exception.backtrace.join("\n"), subject.trace
    end

  end

end