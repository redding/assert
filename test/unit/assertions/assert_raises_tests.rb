require 'assert'
require 'assert/assertions'

module Assert::Assertions

  class AssertRaisesTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_raises`"
    setup do
      d = @d = "assert raises fail desc"
      @test = Factory.test do
        assert_raises(StandardError, RuntimeError){ raise(StandardError) } # pass
        assert_raises(StandardError, RuntimeError, d){ raise(Exception) }  # fail
        assert_raises(RuntimeError, d){ raise(StandardError) }             # fail
        assert_raises(RuntimeError, d){ true }                             # fail
        assert_raises(d){ true }                                           # fail
      end
      @test.run(&test_run_callback)
    end
    subject{ @test }

    should "produce results as expected" do
      assert_equal 5, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 4, test_run_result_count(:fail)
    end

    should "have a fail message with custom and generic explanations" do
      exp = [
        "#{@d}\nStandardError or RuntimeError exception expected, not:",
        "#{@d}\nRuntimeError exception expected, not:",
        "#{@d}\nRuntimeError exception expected but nothing raised.",
        "#{@d}\nAn exception expected but nothing raised."
      ]
      messages = test_run_results(:fail).map(&:message)
      messages.each_with_index{ |msg, n| assert_match /^#{exp[n]}/, msg }
    end

    should "return any raised exception instance" do
      error     = nil
      error_msg = Factory.string
      test = Factory.test do
        error = assert_raises(RuntimeError){ raise(RuntimeError, error_msg) }
      end
      test.run

      assert_not_nil error
      assert_kind_of RuntimeError, error
      assert_equal error_msg, error.message

      test = Factory.test do
        error = assert_raises(RuntimeError){ }
      end
      test.run

      assert_nil error
    end

  end

  class AssertNothingRaisedTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_nothing_raised`"
    setup do
      d = @d = "assert nothing raised fail desc"
      @test = Factory.test do
        anr = :assert_nothing_raised
        self.send(anr, StandardError, RuntimeError, d){ raise(StandardError) } # fail
        self.send(anr, RuntimeError){ raise(StandardError) }                   # pass
        self.send(anr, d){ raise(RuntimeError) }                               # fail
        self.send(anr){ true }                                                 # pass
      end
      @test.run(&test_run_callback)
    end
    subject{ @test }

    should "produce results as expected" do
      assert_equal 4, test_run_result_count
      assert_equal 2, test_run_result_count(:pass)
      assert_equal 2, test_run_result_count(:fail)
    end

    should "have a fail message with custom and generic explanations" do
      exp = [
        "#{@d}\nStandardError or RuntimeError exception not expected, but raised:",
        "#{@d}\nAn exception not expected, but raised:"
      ]
      messages = test_run_results(:fail).map(&:message)
      messages.each_with_index{ |msg, n| assert_match /^#{exp[n]}/, msg }
    end

  end

end

