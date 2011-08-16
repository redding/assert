require 'assert'

require 'assert/result'

module Assert::Result

  class BacktraceTest < Assert::Context
    desc "a result backtrace"
    setup{ @backtrace = Backtrace.new(caller) }
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

  class BaseTest < Assert::Context
    desc "a base result"
    setup do
      @result = Assert::Result::Base.new("a test name", "a message", ["line 1", "line2"])
    end
    subject{ @result }

    should have_readers :test_name, :message, :backtrace
    should have_instance_methods :to_sym, :to_s, :trace

    Assert::Result.types.keys.each do |type|
      should "respond to the instance method ##{type}?" do
        assert_respond_to subject, "#{type}?"
      end

      should "not be #{type}" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "nil out empty messages" do
      assert_equal nil, Assert::Result::Base.new("a test name", "").message
    end

    should "show only its class and message when inspected" do
      assert_equal "#<#{subject.class} @message=#{subject.message.inspect}>", subject.inspect
    end

  end

  class ToStringTest < BaseTest
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

  class PassTest < Assert::Context
    desc "a pass result"
    setup do
      @result = Assert::Result::Pass.new("test", "passed", [])
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
      assert_equal :passed, subject.to_sym
    end

    should "include PASS in its to_s" do
      assert subject.to_s.include?("PASS")
    end
  end

  class FailTest < Assert::Context
    desc "a fail result"
    setup do
      @result = Assert::Result::Fail.new("test", "failed", [])
    end
    subject { @result }

    should "be fail?" do
      assert_equal true, subject.fail?
    end

    Assert::Result.types.keys.reject{|k| k == :fail}.each do |type|
      should "not be #{type}?" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "know its to_sym" do
      assert_equal :failed, subject.to_sym
    end

    should "include FAIL in its to_s" do
      assert subject.to_s.include?("FAIL")
    end
  end

  class IgnoreTest < Assert::Context
    desc "an ignore result"
    setup do
      @result = Assert::Result::Ignore.new("test", "ignored", [])
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
      assert_equal :ignored, subject.to_sym
    end

    should "include IGNORE in its to_s" do
      assert subject.to_s.include?("IGNORE")
    end
  end

  class FromExceptionTest < Assert::Context
    before do
      begin
        raise Exception, "test error"
      rescue Exception => err
        @exception = err
      end
      @result = Assert::Result::FromException.new("test", @exception)
    end
    subject{ @result }

    should "have the same backtrace as the original exception it was created from" do
      assert_equal @exception.backtrace, subject.backtrace
    end

  end

  class SkippedRuntimeErrorTest < Assert::Context

    should "be a runtime error" do
      assert_kind_of RuntimeError, Assert::Result::TestSkipped.new
    end

  end

  class SkipTest < FromExceptionTest
    desc "a skip result"
    setup do
      @result = Assert::Result::Skip.new("test", @exception)
    end
    subject { @result }

    should "be skip?" do
      assert_equal true, subject.skip?
    end

    Assert::Result.types.keys.reject{|k| k == :skip}.each do |type|
      should "not be #{type}?" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "know its to_sym" do
      assert_equal :skipped, subject.to_sym
    end

    should "include SKIP in its to_s" do
      assert subject.to_s.include?("SKIP")
    end
  end

  class ErrorTest < FromExceptionTest
    desc "an error result"
    setup do
      @result = Assert::Result::Error.new("test", @exception)
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
      assert_equal :errored, subject.to_sym
    end

    should "include ERRORED in its to_s" do
      assert subject.to_s.include?("ERROR")
    end

    should "have a trace created from the original exception's unfiltered backtrace" do
      assert_equal @exception.backtrace.join("\n"), subject.trace
    end
  end

end
