require 'assert'
require 'assert/result'

module Assert::Result

  class UnitTests < Assert::Context
    desc "Assert::Result"
    setup do
      @test = Factory.test("a test name")
    end
    subject{ Assert::Result }

    should have_imeths :types

    should "know its types" do
      exp = {
        :pass   => Pass,
        :fail   => Fail,
        :ignore => Ignore,
        :skip   => Skip,
        :error  => Error
      }
      assert_equal exp, subject.types
    end

  end

  class BaseTests < UnitTests
    desc "Base"
    setup do
      @message = Factory.text
      @bt      = Factory.integer(3).times.map{ Factory.string }

      @result = Assert::Result::Base.new(@test, @message, @bt)
    end
    subject{ @result }

    should have_cmeths :type, :name
    should have_readers :test, :data
    should have_imeths :type, :name, :test_name, :message, :backtrace, :trace
    should have_imeths :to_sym, :to_s
    should have_imeths *Assert::Result.types.keys.map{ |k| "#{k}?" }
    should have_imeth :set_backtrace

    should "know its class-level type/name" do
      assert_equal :unknown, subject.class.type
      assert_equal '',       subject.class.name
    end

    should "know its test" do
      assert_equal @test, subject.test
    end

    should "know its data and its data related attrs" do
      assert_kind_of Data, subject.data

      data          = subject.data
      exp_backtrace = Backtrace.new(@bt)
      exp_trace     = exp_backtrace.filtered.first.to_s

      assert_equal subject.class.type, data.type
      assert_equal subject.class.name, data.name
      assert_equal @test.name,         data.test_name
      assert_equal @message,           data.message
      assert_equal exp_backtrace,      data.backtrace
      assert_equal exp_trace,          data.trace

      assert_equal data.type,      subject.type
      assert_equal data.name,      subject.name
      assert_equal data.test_name, subject.test_name
      assert_equal data.message,   subject.message
      assert_equal data.backtrace, subject.backtrace
      assert_equal data.trace,     subject.trace
      assert_equal data.to_sym,    subject.to_sym
      assert_equal data.to_s,      subject.to_s

      Assert::Result.types.keys.each do |type|
        assert_equal data.send("#{type}?"), subject.send("#{type}?")
      end
    end

    should "allow setting a new backtrace" do
      new_bt        = Factory.integer(3).times.map{ Factory.string }
      exp_backtrace = Backtrace.new(new_bt)
      exp_trace     = exp_backtrace.filtered.first.to_s

      subject.set_backtrace(new_bt)

      assert_equal exp_backtrace, subject.backtrace
      assert_equal exp_trace,     subject.trace
    end

    should "know if it is equal to another result" do
      other = Assert::Result::Base.new(@test, @message, @bt)
      assert_equal other, subject

      Assert.stub(other, [:type, :message].choice){ Factory.string }
      assert_not_equal other, subject
    end

    should "show only its class and message when inspected" do
      exp = "#<#{subject.class}:#{'0x0%x' % (subject.object_id << 1)}"\
            " @message=#{subject.message.inspect}>"
      assert_equal exp, subject.inspect
    end

  end

  class PassTests < UnitTests
    desc "Pass"
    setup do
      @result = Assert::Result::Pass.new(@test, '', [])
    end
    subject { @result }

    should "know its class-level type/name" do
      assert_equal :pass,  subject.class.type
      assert_equal 'Pass', subject.class.name
    end

  end

  class IgnoreTests < UnitTests
    desc "Ignore"
    setup do
      @result = Assert::Result::Ignore.new(@test, '', [])
    end
    subject { @result }

    should "know its class-level type/name" do
      assert_equal :ignore,  subject.class.type
      assert_equal 'Ignore', subject.class.name
    end

  end

  class TestFailureTests < UnitTests
    desc "TestFailure"
    subject{ TestFailure }

    should "be a runtime error" do
      assert_kind_of RuntimeError, subject.new
    end

  end

  class FailTests < UnitTests
    desc "Fail"
    setup do
      @result = Assert::Result::Fail.new(@test, '', [])
    end
    subject { @result }

    should "know its class-level type/name" do
      assert_equal :fail,  subject.class.type
      assert_equal 'Fail', subject.class.name
    end

    should "allow building from TestFailure exceptions" do
      err = TestFailure.new
      err.set_backtrace(caller)

      result = Assert::Result::Fail.new(@test, err)
      assert_equal err.message, result.message

      exp_bt = Backtrace.new(err.backtrace)
      assert_equal exp_bt, result.backtrace
    end

    should "not allow building from non-TestFailure exceptions" do
      assert_raises ArgumentError do
        result = Assert::Result::Fail.new(@test, RuntimeError.new)
      end
    end

  end

  class TestSkippedTests < UnitTests
    desc "TestSkipped"
    subject{ TestSkipped }

    should "be a runtime error" do
      assert_kind_of RuntimeError, subject.new
    end

  end

  class SkipTests < UnitTests
    desc "Skip"
    setup do
      @err = TestSkipped.new
      @err.set_backtrace(caller)
      @result = Assert::Result::Skip.new(@test, @err)
    end
    subject { @result }

    should "know its class-level type/name" do
      assert_equal :skip,  subject.class.type
      assert_equal 'Skip', subject.class.name
    end

    should "use the TestSkipped err attrs for its attrs" do
      assert_equal @err.message, subject.message

      exp_bt = Backtrace.new(@err.backtrace)
      assert_equal exp_bt, subject.backtrace
    end

    should "not allow building from non-TestSkipped exceptions" do
      assert_raises ArgumentError do
        result = Assert::Result::Skip.new(@test, RuntimeError.new)
      end
    end

  end

  class ErrorTests < UnitTests
    desc "Error"
    setup do
      @err = Exception.new
      @err.set_backtrace(caller)
      @result = Assert::Result::Error.new(@test, @err)
    end
    subject { @result }

    should "know its class-level type/name" do
      assert_equal :error,  subject.class.type
      assert_equal 'Error', subject.class.name
    end

    should "use the errors attrs for its attrs" do
      exp_msg = "#{@err.message} (#{@err.class.name})"
      assert_equal exp_msg, subject.message

      exp_bt = Backtrace.new(@err.backtrace)
      assert_equal exp_bt, subject.backtrace
    end

    should "use the unfiltered backtrace as its trace" do
      assert_equal Backtrace.new(@err.backtrace).to_s, subject.trace
    end

    should "not allow building without an exception" do
      assert_raises ArgumentError do
        result = Assert::Result::Error.new(@test, Factory.string)
      end
    end

  end

  class DataTests < UnitTests
    desc "Data"
    setup do
      @given_data = {
        :type      => Factory.string,
        :name      => Factory.string,
        :test_name => Factory.string,
        :message   => Factory.string,
        :backtrace => Backtrace.new(caller),
        :trace     => Factory.string
      }

      @data = Data.new(@given_data)
    end
    subject{ @data }

    should have_accessors :type, :name, :test_name, :message, :backtrace, :trace
    should have_imeths :to_sym, :to_s
    should have_imeths *Assert::Result.types.keys.map{ |k| "#{k}?" }

    should "use any given attrs" do
      assert_equal @given_data[:type].to_sym, subject.type
      assert_equal @given_data[:name],        subject.name
      assert_equal @given_data[:test_name],   subject.test_name
      assert_equal @given_data[:message],     subject.message
      assert_equal @given_data[:backtrace],   subject.backtrace
      assert_equal @given_data[:trace],       subject.trace
    end

    should "default its attrs" do
      data = Data.new

      assert_equal :unknown, data.type
      assert_equal '',       data.name
      assert_equal '',       data.test_name
      assert_equal '',       data.message
      assert_equal [],       data.backtrace
      assert_equal '',       data.trace
    end

    should "know its symbol representation" do
      assert_equal subject.type, subject.to_sym
    end

    should "know its string representation" do
      str = subject.to_s

      assert_includes subject.name.upcase, str
      assert_includes subject.test_name,   str
      assert_includes subject.message,     str
      assert_includes subject.trace,       str

      assert_equal 3, str.split("\n").count

      subject.message = ''
      subject.trace   = ''

      assert_equal 1, subject.to_s.split("\n").count
    end

  end

  class BacktraceTests < UnitTests
    desc "Backtrace"
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

end
