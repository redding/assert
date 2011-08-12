require 'assert'

class Assert::Assertions::AssertRaisesTest < Assert::Context
  desc "the assert_raises helper run in a test"
  setup do
    fail_desc = @fail_desc = "assert raises fail desc"
    @test = Factory.test do
      assert_raises(StandardError, RuntimeError){ raise(StandardError) }          # pass
      assert_raises(StandardError, RuntimeError, fail_desc){ raise(Exception) }   # fail
      assert_raises(RuntimeError, fail_desc){ raise(StandardError) }              # fail
      assert_raises(RuntimeError, fail_desc){ true }                              # fail
      assert_raises(fail_desc){ true }                                            # fail
    end
    @test.run
  end
  subject{ @test }

  should "have 3 total results" do
    assert_equal 5, subject.result_count
  end
  should "have 1 pass result" do
    assert_equal 1, subject.result_count(:pass)
  end
  should "have 4 fail results" do
    assert_equal 4, subject.result_count(:fail)
  end

  class FailMessageTest < AssertRaisesTest
    desc "with a failed result"
    setup do
      @expected = [
        "#{@fail_desc}\nStandardError or RuntimeError exception expected, not:",
        "#{@fail_desc}\nRuntimeError exception expected, not:",
        "#{@fail_desc}\nRuntimeError exception expected but nothing was raised.",
        "#{@fail_desc}\nAn exception expected but nothing was raised."
      ]
      @fail_messages = @test.fail_results.collect(&:message)
    end
    subject{ @fail_messages }

    should "have a fail message with an explanation of what failed and my fail description" do
      subject.each_with_index do |message, n|
        assert_match /^#{@expected[n]}/, message
      end
    end

  end

end
