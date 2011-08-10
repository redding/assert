require 'test_belt'
require 'assert/context'
require 'assert/test'

module Assert::Assertions

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    setup do
      @context_klass = Class.new(Assert::Context)
      @context = @context_klass.new
    end

    subject{ @context }

    should have_instance_methods :assert_block
    should have_instance_methods :assert_raises, :assert_raise
    should have_instance_methods :assert_kind_of, :assert_instance_of
    should have_instance_methods :assert_respond_to
    should have_instance_methods :assert_same, :assert_equal, :assert_match

    should have_instance_methods :assert_not_block, :refute_block
    should have_instance_methods :assert_nothing_raised, :assert_not_raises, :assert_not_raise
    should have_instance_methods :refute_kind_of, :refute_instance_of
    should have_instance_methods :refute_respond_to
    should have_instance_methods :refute_same, :refute_equal, :refute_match

  end

  class AssertBlockTest < BasicTest

    setup do
      @test = Assert::Test.new("assert block test", lambda do
        assert_block{ true }
        assert_block{ false }
      end, @context_klass)
      @test.run
    end
    subject{ @test }

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    class MessagesTest < AssertBlockTest

      setup do
        fail_desc = "assert block shouldn't fail!"
        @test = Assert::Test.new("assert block message test", lambda do
          assert_block(fail_desc){ false }
        end, @context_klass)
        @expected_message = "Expected block to return true value.\n#{fail_desc}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertNotBlockTest < BasicTest

    setup do
      @test = Assert::Test.new("assert not block test", lambda do
        assert_not_block{ true }
        assert_not_block{ false }
      end, @context_klass)
      @test.run
    end

    subject{ @test }

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    class MessagesTest < AssertNotBlockTest

      setup do
        fail_desc = "assert not block shouldn't fail!"
        @test = Assert::Test.new("assert not block message test", lambda do
          assert_not_block(fail_desc){ true }
        end, @context_klass)
        @expected_message = "Expected block to return false value.\n#{fail_desc}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertRaisesTest < BasicTest

    setup do
      @test = Assert::Test.new("assert raises test", lambda do
        assert_raises(StandardError, RuntimeError){ raise(StandardError) }  # pass
        assert_raises(RuntimeError){ raise(StandardError) }                 # fail
        assert_raises{ true }                                               # fail
      end, @context_klass)
      @test.run
    end
    subject{ @test }

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 2 fail results" do
      assert_equal 2, subject.result_count(:fail)
    end

    class MessagesTest < AssertRaisesTest

      setup do
        fail_desc = "assert raises shouldn't fail"
        @test = Assert::Test.new("assert raises message test", lambda do
          assert_raises(StandardError, RuntimeError, fail_desc){ raise(Exception) }
          assert_raises(RuntimeError, fail_desc){ raise(StandardError) }
          assert_raises(RuntimeError, fail_desc){ true }
          assert_raises(fail_desc){ true }
        end, @context_klass)
        @expected_message = [
          "#{fail_desc}\nStandardError or RuntimeError exception expected, not:",
          "#{fail_desc}\nRuntimeError exception expected, not:",
          "#{fail_desc}\nRuntimeError exception expected but nothing was raised.",
          "#{fail_desc}\nAn exception expected but nothing was raised."
        ]
        @test.run
        @messages = @test.fail_results.collect(&:message)
      end
      subject{ @messages }

      should "have the correct failure messages" do
        subject.each_with_index do |message, n|
          assert(message.include?(@expected_message[n]))
        end
      end

    end

  end

  class AssertNothingRaisedTest < BasicTest

    setup do
      @test = Assert::Test.new("assert nothing raised test", lambda do
        assert_nothing_raised(StandardError){ raise(StandardError) }  # fail
        assert_nothing_raised(RuntimeError){ raise(StandardError) }   # pass
        assert_nothing_raised{ raise(RuntimeError) }                  # fail
        assert_nothing_raised{ true }                                 # pass
      end, @context_klass)
      @test.run
    end

    subject{ @test }

    should "have 2 pass result" do
      assert_equal 2, subject.result_count(:pass)
    end

    should "have 2 fail result" do
      assert_equal 2, subject.result_count(:fail)
    end

    class MessagesTest < AssertRaisesTest

      setup do
        fail_desc = "assert nothing raised shouldn't fail"
        @test = Assert::Test.new("assert nothing raised message test", lambda do
          assert_nothing_raised(StandardError, RuntimeError, fail_desc){ raise(StandardError) }
          assert_nothing_raised(fail_desc){ raise(RuntimeError) }
        end, @context_klass)
        @expected_message = [
          "#{fail_desc}\nStandardError or RuntimeError exception was not expected, but was raised:",
          "#{fail_desc}\nAn exception was not expected, but was raised:"
        ]
        @test.run
        @messages = @test.fail_results.collect(&:message)
      end
      subject{ @messages }

      should "have the correct failure messages" do
        subject.each_with_index do |message, n|
          assert(message.include?(@expected_message[n]))
        end
      end

    end

  end

end
