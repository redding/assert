root_path = File.expand_path("../../..", __FILE__)
if !$LOAD_PATH.include?(root_path)
  $LOAD_PATH.unshift(root_path)
end
require 'test/helper'

class Assert::Assertions::AssertNothingRaisedTest < Assert::Context
  desc "the assert_nothing_raised helper run in a test"
  setup do
    fail_desc = @fail_desc = "assert nothing raised fail desc"
    @test = Factory.test do
      assert_nothing_raised(StandardError, RuntimeError, fail_desc){ raise(StandardError) }   # fail
      assert_nothing_raised(RuntimeError){ raise(StandardError) }                             # pass
      assert_nothing_raised(fail_desc){ raise(RuntimeError) }                                 # fail
      assert_nothing_raised{ true }                                                           # pass
    end
    @test.run
  end
  subject{ @test }

  should "have 4 total results" do
    assert_equal 4, subject.result_count
  end
  should "have 2 pass result" do
    assert_equal 2, subject.result_count(:pass)
  end
  should "have 2 fail result" do
    assert_equal 2, subject.result_count(:fail)
  end



  class FailMessageTest < AssertNothingRaisedTest
    desc "with a failed result"
    setup do
      @expected = [
        "#{@fail_desc}\nStandardError or RuntimeError exception was not expected, but was raised:",
        "#{@fail_desc}\nAn exception was not expected, but was raised:"
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
