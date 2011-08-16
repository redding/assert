require 'assert'

class Assert::Assertions::AssertNotSameTest < Assert::Context
  desc "the assert_not_same helper run in a test"
  setup do
    klass = Class.new
    object = klass.new
    fail_desc = @fail_desc = "assert not same fail desc"
    fail_args = @fail_args = [ object, object, fail_desc ]
    @test = Factory.test do
      assert_not_same(*fail_args)         # fail
      assert_not_same(object, klass.new)  # pass
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

  class FailMessageTest < AssertNotSameTest
    desc "with a failed result"
    setup do
      @expected = [
        @fail_args[2],
        "#{@fail_args[0].inspect} (#{@fail_args[0].object_id}) not expected to be the same as #{@fail_args[1].inspect} (#{@fail_args[1].object_id}).",
      ].join("\n")
      @fail_message = @test.fail_results.first.message
    end
    subject{ @fail_message }

    should "have a fail message with an explanation of what failed and my fail description" do
      assert_equal @expected, subject
    end

  end

end
