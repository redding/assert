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
      fail_desc = "shouldn't fail!"
      @test = Assert::Test.new("assert block test", lambda do
        assert_block{ true }
        assert_block(fail_desc){ false }
      end, @context_klass)
      @expected_message = "Expected block to return true value.\n#{fail_desc}"
      @test.run
    end

    subject{ @test }

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    should "have the correct failure message" do
      fail_result = subject.fail_results.first
      assert_equal @expected_message, fail_result.message
    end

  end

  class AssertNotBlockTest < BasicTest

    setup do
      fail_desc = "shouldn't fail!"
      @test = Assert::Test.new("assert not block test", lambda do
        assert_not_block(fail_desc){ true }
        assert_not_block{ false }
      end, @context_klass)
      @expected_message = "Expected block to return false value.\n#{fail_desc}"
      @test.run
    end

    subject{ @test }

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    should "have the correct failure message" do
      fail_result = subject.fail_results.first
      assert_equal @expected_message, fail_result.message
    end

  end

  # TODO: check message passing
  class AssertRaisesTest < BasicTest

    setup do
      @test = Assert::Test.new("assert raises test", lambda do
        assert_raises(StandardError){ raise(StandardError) }  # pass
        assert_raises(RuntimeError){ raise(StandardError) }   # fail
        assert_raises{ true }                                 # fail
      end, @context_klass)
      @test.run
    end

    subject{ @test }

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 2 fail result" do
      assert_equal 2, subject.result_count(:fail)
    end

  end

  # TODO: check message passing
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

  end

end
