require 'assert'

class Assert::Assertions::AssertIncludes < Assert::Context
  desc "the assert_includes helper run in a test"
  setup do

    fail_desc = @fail_desc = "assert includes fail desc"
    fail_args = @fail_args = [ 2, [ 1 ], fail_desc ]
    @test = Factory.test do
      assert_includes(1, [ 1 ])      # pass
      assert_includes(*fail_args)    # fail
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

  class FailMessageTest < AssertIncludes
    desc "with a failed result"
    setup do
      @expected = [
        @fail_args[2],
        "Expected #{@fail_args[1].inspect} to include #{@fail_args[0].inspect}."
      ].join("\n")
      @fail_message = @test.fail_results.first.message
    end
    subject{ @fail_message }

    should "have a fail message with an explanation of what failed and my fail description" do
      assert_equal @expected, subject
    end

  end

end
