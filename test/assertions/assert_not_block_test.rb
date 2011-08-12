require 'assert'

class Assert::Assertions::AssertNotBlockTest < Assert::Context
  desc "the assert_not_block helper run in a test"
  setup do
    fail_desc = @fail_desc = "assert not block fail desc"
    @test = Factory.test do
      assert_not_block(fail_desc){ true }
      assert_not_block{ false }
    end
    @test.run
  end
  subject{ @test }

  should "have 2 total results" do
    assert_equal 2, subject.result_count
  end
  should "have 1 pass result" do
    assert_equal 1, subject.result_count(:pass)
  end
  should "have 1 fail result" do
    assert_equal 1, subject.result_count(:fail)
  end

  class FailMessageTest < AssertNotBlockTest
    desc "with a failed result"
    setup do
      @expected = [ "Expected block to return false value.", @fail_desc ].join("\n")
      @fail_message = @test.fail_results.first.message
    end
    subject{ @fail_message }

    should "have a fail message with an explanation of what failed and my fail description" do
      assert_equal @expected, subject
    end

  end

end
