require 'test_belt'

require 'assert/result'

module Assert::Result

  class BacktraceTest < Test::Unit::TestCase
    include TestBelt

    context "a result backtrace"
    subject { Backtrace.new(caller) }

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

  class BaseTest < Test::Unit::TestCase
    include TestBelt

    context "a base result"
    subject do
      Assert::Result::Base.new("a test name", "a message", ["line 1", "line2"])
    end

    should have_readers :test_name, :message, :abbrev, :caller
    should have_instance_methods :to_sym, :to_s, :trace

    Assert::Result.types.keys.each do |type|
      should have_instance_method "#{type}?"

      should "not be #{type}" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "nil out empty messages" do
      assert_equal nil, Assert::Result::Base.new("a test name", "").message
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

  class PassTest < Test::Unit::TestCase
    include TestBelt

    context "a pass result"
    subject { Assert::Result::Pass.new("test", "passed", []) }

    should "be pass?" do
      assert_equal true, subject.pass?
    end

    Assert::Result.types.keys.reject{|k| k == :pass}.each do |type|
      should "not be #{type}?" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "show '.' for its abbrev" do
      assert_equal '.', subject.abbrev
    end

    should "know its to_sym" do
      assert_equal :passed, subject.to_sym
    end

    should "include PASS in its to_s" do
      assert subject.to_s.include?("PASS")
    end
  end

  class FailTest < Test::Unit::TestCase
    include TestBelt

    context "a fail result"
    subject { Assert::Result::Fail.new("test", "failed", []) }

    should "be fail?" do
      assert_equal true, subject.fail?
    end

    Assert::Result.types.keys.reject{|k| k == :fail}.each do |type|
      should "not be #{type}?" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "show 'F' for its abbrev" do
      assert_equal 'F', subject.abbrev
    end

    should "know its to_sym" do
      assert_equal :failed, subject.to_sym
    end

    should "include FAIL in its to_s" do
      assert subject.to_s.include?("FAIL")
    end
  end

  class IgnoreTest < Test::Unit::TestCase
    include TestBelt

    context "an ignore result"
    subject { Assert::Result::Ignore.new("test", "ignored", []) }

    should "be ignore?" do
      assert_equal true, subject.ignore?
    end

    Assert::Result.types.keys.reject{|k| k == :ignore}.each do |type|
      should "not be #{type}?" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "show 'I' for its abbrev" do
      assert_equal 'I', subject.abbrev
    end

    should "know its to_sym" do
      assert_equal :ignored, subject.to_sym
    end

    should "include IGNORE in its to_s" do
      assert subject.to_s.include?("IGNORE")
    end
  end

  class FromExceptionTest < Test::Unit::TestCase
    include TestBelt

    before do
      begin
        raise Exception, "test error"
      rescue Exception => err
        @exception = err
      end
    end

    subject do
      Assert::Result::FromException.new("test", @exception)
    end

    should "have the same backtrace as the original exception it was created from" do
      assert_equal @exception.backtrace, subject.backtrace
    end

  end

  class SkippedRuntimeErrorTest < Test::Unit::TestCase
    include TestBelt

    should "be a runtime error" do
      assert_kind_of RuntimeError, Assert::Result::TestSkipped.new
    end
  end

  class SkipTest < FromExceptionTest
    context "a skip result"
    subject { Assert::Result::Skip.new("test", @exception) }

    should "be skip?" do
      assert_equal true, subject.skip?
    end

    Assert::Result.types.keys.reject{|k| k == :skip}.each do |type|
      should "not be #{type}?" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "show 'S' for its abbrev" do
      assert_equal 'S', subject.abbrev
    end

    should "know its to_sym" do
      assert_equal :skipped, subject.to_sym
    end

    should "include SKIP in its to_s" do
      assert subject.to_s.include?("SKIP")
    end
  end

  class ErrorTest < FromExceptionTest
    context "an error result"
    subject do
      Assert::Result::Error.new("test", @exception)
    end

    should "be error?" do
      assert_equal true, subject.error?
    end

    Assert::Result.types.keys.reject{|k| k == :error}.each do |type|
      should "not be #{type}?" do
        assert_equal false, subject.send("#{type}?")
      end
    end

    should "show 'E' for its abbrev" do
      assert_equal 'E', subject.abbrev
    end

    should "know its to_sym" do
      assert_equal :errored, subject.to_sym
    end

    should "include ERRORED in its to_s" do
      assert subject.to_s.include?("ERRORED")
    end

    should "have a trace created from the original exception's unfiltered backtrace" do
      assert_equal @exception.backtrace.join("\n"), subject.trace
    end
  end

end
