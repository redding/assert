require 'assert'

class Assert::Assertions::AssertSameTest < Assert::Context
  desc "the assert_same helper run in a test"
  setup do
    klass = Class.new
    object = klass.new
    fail_desc = @fail_desc = "assert same fail desc"
    fail_args = @fail_args = [ object, klass.new, fail_desc ]
    @test = Factory.test do
      assert_same(object, object)     # pass
      assert_same(*fail_args)         # fail
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

  class FailMessageTest < AssertSameTest
    desc "with a failed result"
    setup do
      @expected = [
        "Expected #{@fail_args[0].inspect} (#{@fail_args[0].object_id}) to be the same as ",
        "#{@fail_args[1].inspect} (#{@fail_args[1].object_id}).",
        "\n#{@fail_args[2]}"
      ].join
      @fail_message = @test.fail_results.first.message
    end
    subject{ @fail_message }

    should "have a fail message with an explanation of what failed and my fail description" do
      assert_equal @expected, subject
    end

  end

end
