require 'assert'
require 'assert/assertions'

module Assert::Assertions

  class AssertRaisesTests < Assert::Context
    desc "the assert_raises helper"
    setup do
      d = @d = "assert raises fail desc"
      @test = Factory.test do
        assert_raises(StandardError, RuntimeError){ raise(StandardError) } # pass
        assert_raises(StandardError, RuntimeError, d){ raise(Exception) }  # fail
        assert_raises(RuntimeError, d){ raise(StandardError) }             # fail
        assert_raises(RuntimeError, d){ true }                             # fail
        assert_raises(d){ true }                                           # fail
      end
      @test.run
    end
    subject{ @test }

    should "produce results as expected" do
      assert_equal 5, subject.result_count
      assert_equal 1, subject.result_count(:pass)
      assert_equal 4, subject.result_count(:fail)
    end

    should "have a fail message with custom and generic explanations" do
      exp = [
        "#{@d}\nStandardError or RuntimeError exception expected, not:",
        "#{@d}\nRuntimeError exception expected, not:",
        "#{@d}\nRuntimeError exception expected but nothing raised.",
        "#{@d}\nAn exception expected but nothing raised."
      ]
      messages = @test.fail_results.map(&:message)
      messages.each_with_index{ |msg, n| assert_match /^#{exp[n]}/, msg }
    end

  end

  class AssertNothingRaisedTests < Assert::Context
    desc "the assert_nothing_raised helper"
    setup do
      d = @d = "assert nothing raised fail desc"
      @test = Factory.test do
        anr = :assert_nothing_raised
        self.send(anr, StandardError, RuntimeError, d){ raise(StandardError) } # fail
        self.send(anr, RuntimeError){ raise(StandardError) }                   # pass
        self.send(anr, d){ raise(RuntimeError) }                               # fail
        self.send(anr){ true }                                                 # pass
      end
      @test.run
    end
    subject{ @test }

    should "produce results as expected" do
      assert_equal 4, subject.result_count
      assert_equal 2, subject.result_count(:pass)
      assert_equal 2, subject.result_count(:fail)
    end

    should "have a fail message with custom and generic explanations" do
      exp = [
        "#{@d}\nStandardError or RuntimeError exception not expected, but raised:",
        "#{@d}\nAn exception not expected, but raised:"
      ]
      messages = @test.fail_results.map(&:message)
      messages.each_with_index{ |msg, n| assert_match /^#{exp[n]}/, msg }
    end

  end

end

