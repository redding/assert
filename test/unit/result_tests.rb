require 'assert'
require 'assert/result'

module Assert::Result

  class UnitTests < Assert::Context
    desc "Assert::Result"
    setup do
      @test = Factory.test("a test name")
    end
    subject{ Assert::Result }

    should have_imeths :types, :new

    should "know its types" do
      exp = {
        :pass   => Pass,
        :fail   => Fail,
        :ignore => Ignore,
        :skip   => Skip,
        :error  => Error
      }
      assert_equal exp, subject.types

      assert_equal Base, subject.types[Factory.string]
    end

    should "create results from data hashes" do
      type   = Assert::Result.types.keys.sample
      exp    = Assert::Result.types[type].new(:type => type)

      assert_equal exp, Assert::Result.new(:type => type)
    end

  end

  class BaseTests < UnitTests
    desc "Base"
    setup do
      @given_data = {
        :type      => Factory.string,
        :name      => Factory.string,
        :test_name => Factory.string,
        :test_id   => Factory.string,
        :message   => Factory.string,
        :output    => Factory.text,
        :backtrace => Backtrace.new(caller),
        :trace     => Factory.string
      }
      @result = Base.new(@given_data)
    end
    subject{ @result }

    should have_cmeths :type, :name, :for_test
    should have_imeths :type, :name, :test_name, :test_id
    should have_imeths :message, :output, :backtrace, :trace, :file_line
    should have_imeths *Assert::Result.types.keys.map{ |k| "#{k}?" }
    should have_imeths :set_backtrace, :data, :to_sym, :to_s

    should "know its class-level type/name" do
      assert_equal :unknown, subject.class.type
      assert_equal '',       subject.class.name
    end

    should "know how to build a result for a given test" do
      message = Factory.text
      bt      = Factory.integer(3).times.map{ Factory.string }
      result  = Base.for_test(@test, message, bt)

      exp_backtrace = Backtrace.new(bt)
      exp_trace     = exp_backtrace.filtered.first.to_s

      assert_equal @test.name,           result.test_name
      assert_equal @test.file_line.to_s, result.test_id

      assert_equal message,       result.message
      assert_equal exp_backtrace, result.backtrace
      assert_equal exp_trace,     result.trace
    end

    should "use any given attrs" do
      assert_equal @given_data[:type].to_sym, subject.type
      assert_equal @given_data[:name],        subject.name
      assert_equal @given_data[:test_name],   subject.test_name
      assert_equal @given_data[:test_id],     subject.test_id
      assert_equal @given_data[:message],     subject.message
      assert_equal @given_data[:output],      subject.output
      assert_equal @given_data[:backtrace],   subject.backtrace
      assert_equal @given_data[:trace],       subject.trace
    end

    should "default its attrs" do
      result = Base.new({})

      assert_equal :unknown,          result.type
      assert_equal '',                result.name
      assert_equal '',                result.test_name
      assert_equal '',                result.test_id
      assert_equal '',                result.message
      assert_equal '',                result.output
      assert_equal Backtrace.new([]), result.backtrace
      assert_equal '',                result.trace
    end

    should "know its file line attr" do
      exp = subject.backtrace.filtered.first.to_s
      assert_equal exp, subject.file_line
    end

    should "know if it is a certain type of result" do
      Assert::Result.types.keys.each do |type|
        assert_false subject.send("#{type}?")
        Assert.stub(subject, :type){ type }
        assert_true subject.send("#{type}?")
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

    should "know its data" do
      exp = {
        :type      => subject.type,
        :name      => subject.name,
        :test_name => subject.test_name,
        :test_id   => subject.test_id,
        :message   => subject.message,
        :output    => subject.output,
        :backtrace => subject.backtrace,
        :trace     => subject.trace,
      }
      assert_equal exp, subject.data
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

      Assert.stub(subject, :message){ '' }
      Assert.stub(subject, :trace){ '' }

      assert_equal 1, subject.to_s.split("\n").count
    end

    should "know if it is equal to another result" do
      other = Assert::Result::Base.new(@given_data)
      assert_equal other, subject

      Assert.stub(other, [:type, :message].sample){ Factory.string }
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
      @result = Pass.new({})
    end
    subject { @result }

    should "know its type/name" do
      assert_equal :pass,  subject.type
      assert_equal :pass,  subject.class.type
      assert_equal 'Pass', subject.class.name
    end

  end

  class IgnoreTests < UnitTests
    desc "Ignore"
    setup do
      @result = Ignore.new({})
    end
    subject { @result }

    should "know its type/name" do
      assert_equal :ignore,  subject.type
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
      @result = Fail.new({})
    end
    subject { @result }

    should "know its type/name" do
      assert_equal :fail,  subject.type
      assert_equal :fail,  subject.class.type
      assert_equal 'Fail', subject.class.name
    end

    should "allow creating for a test with TestFailure exceptions" do
      err = TestFailure.new
      err.set_backtrace(caller)
      result = Fail.for_test(@test, err)

      assert_equal err.message, result.message

      exp_bt = Backtrace.new(err.backtrace)
      assert_equal exp_bt, result.backtrace
    end

    should "not allow creating for a test with non-TestFailure exceptions" do
      assert_raises(ArgumentError){ Fail.for_test(@test, RuntimeError.new) }
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
      @result = Skip.new({})
    end
    subject { @result }

    should "know its type/name" do
      assert_equal :skip,  subject.type
      assert_equal :skip,  subject.class.type
      assert_equal 'Skip', subject.class.name
    end

    should "allow creating for a test with TestSkipped exceptions" do
      err = TestSkipped.new
      err.set_backtrace(caller)
      result = Skip.for_test(@test, err)

      assert_equal err.message, result.message

      exp_bt = Backtrace.new(err.backtrace)
      assert_equal exp_bt, result.backtrace
    end

    should "not allow creating for a test with non-TestSkipped exceptions" do
      assert_raises(ArgumentError){ Skip.for_test(@test, RuntimeError.new) }
    end

  end

  class ErrorTests < UnitTests
    desc "Error"
    setup do
      @result = Error.new({})
    end
    subject { @result }

    should "know its class-level type/name" do
      assert_equal :error,  subject.class.type
      assert_equal 'Error', subject.class.name
    end

    should "allow creating for a test with exceptions" do
      err = Exception.new
      err.set_backtrace(caller)
      result = Error.for_test(@test, err)

      exp_msg = "#{err.message} (#{err.class.name})"
      assert_equal exp_msg, result.message

      exp_bt = Backtrace.new(err.backtrace)
      assert_equal exp_bt,      result.backtrace
      assert_equal exp_bt.to_s, result.trace
    end

    should "not allow creating for a test without an exception" do
      assert_raises(ArgumentError){ Error.for_test(@test, Factory.string) }
    end

  end

  class BacktraceTests < UnitTests
    desc "Backtrace"
    setup do
      @backtrace = Backtrace.new(caller)
    end
    subject { @backtrace }

    should have_cmeths :parse
    should have_imeths :to_s, :filtered

    should "be parseable from its string representation" do
      assert_equal subject, Backtrace.parse(subject.to_s)
    end

    should "be an Array" do
      assert_kind_of ::Array, subject
    end

    should "know its DELIM" do
      assert_equal "\n", Backtrace::DELIM
    end

    should "render as a string by joining on the newline" do
      assert_equal subject.join(Backtrace::DELIM), subject.to_s
    end

    should "another backtrace when filtered" do
      assert_kind_of Backtrace, subject
    end

    should "default itself when created from nil" do
      assert_equal ["No backtrace"], Backtrace.new
    end

  end

end
