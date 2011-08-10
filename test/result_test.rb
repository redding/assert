require 'test_belt'

require 'assert/result'

module Assert::Result
  class BaseTest < Test::Unit::TestCase
    include TestBelt

    context "a base result"
    subject do
      Assert::Result::Base.new("a test name", "a message", ["line 1", "line2"])
    end

    should have_readers :test_name, :message, :abbrev, :caller
    should have_instance_methods :to_sym, :to_s, :trace

    RESULTS = [:pass?, :fail?, :error?, :skip?]
    should have_instance_methods *RESULTS

    RESULTS.each do |meth|
      should "not be #{meth}" do
        assert_equal false, subject.send(meth)
      end
    end
  end

  class ToStringTest < BaseTest
    should "include its test name in the to_s" do
      assert subject.to_s.include?(subject.test_name)
    end

    should "include its message in the to_s" do
      assert subject.to_s.include?(subject.message)
    end

    should "include its trace in the to_s" do
      assert subject.to_s.include?(subject.trace)
    end

    should "have a trace with the first non-assert-framework line of the backtrace" do
      skip
    end
  end

  class PassTest < Test::Unit::TestCase
    include TestBelt

    context "a pass result"
    subject { Assert::Result::Pass.new("test", "passed", []) }

    should "be pass?" do
      assert_equal true, subject.pass?
    end

    NOT_RESULTS = [:fail?, :error?, :skip?]
    NOT_RESULTS.each do |meth|
      should "not be #{meth}" do
        assert_equal false, subject.send(meth)
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

    NOT_RESULTS = [:pass?, :error?, :skip?]
    NOT_RESULTS.each do |meth|
      should "not be #{meth}" do
        assert_equal false, subject.send(meth)
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

  # TODO: ignored result

  class SkippedRuntimeErrorTest < Test::Unit::TestCase
    include TestBelt

    should "be a runtime error" do
      assert_kind_of RuntimeError, Assert::Result::TestSkipped.new
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

  class SkipTest < FromExceptionTest
    context "a skip result"
    subject { Assert::Result::Skip.new("test", @exception) }

    should "be skip?" do
      assert_equal true, subject.skip?
    end

    NOT_RESULTS = [:pass?, :fail?, :error?]
    NOT_RESULTS.each do |meth|
      should "not be #{meth}" do
        assert_equal false, subject.send(meth)
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

    NOT_RESULTS = [:pass?, :fail?, :skip?]
    NOT_RESULTS.each do |meth|
      should "not be #{meth}" do
        assert_equal false, subject.send(meth)
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
