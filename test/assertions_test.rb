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
    should have_instance_methods :assert_not_kind_of, :refute_kind_of
    should have_instance_methods :assert_not_instance_of, :refute_instance_of
    should have_instance_methods :assert_not_respond_to, :refute_respond_to
    should have_instance_methods :assert_not_same, :refute_same
    should have_instance_methods :assert_not_equal, :refute_equal
    should have_instance_methods :assert_not_match, :assert_no_match, :refute_match

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
      skip  # TODO: its calling assertion_result and creating an error result
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



  class AssertKindOfTest < BasicTest

    setup do
      @test = Assert::Test.new("assert kind of test", lambda do
        assert_kind_of(String, "object")  # pass
        assert_kind_of(Array, "object")   # fail
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

    class MessagesTest < AssertKindOfTest

      setup do
        args = [ Array, "object", "assert kind of shouldn't fail!" ]
        @test = Assert::Test.new("assert kind of message test", lambda do
          assert_kind_of(*args)
        end, @context_klass)
        @expected_message = "Expected #{args[1].inspect} to be a kind of #{args[0]}, not #{args[1].class}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertNotKindOfTest < BasicTest

    setup do
      @test = Assert::Test.new("assert not kind of test", lambda do
        assert_not_kind_of(String, "object")  # fail
        assert_not_kind_of(Array, "object")   # pass
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

    class MessagesTest < AssertNotKindOfTest

      setup do
        args = [ String, "object", "assert not kind of shouldn't fail!" ]
        @test = Assert::Test.new("assert not kind of message test", lambda do
          assert_not_kind_of(*args)
        end, @context_klass)
        @expected_message = "#{args[1].inspect} was not expected to be a kind of #{args[0]}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end



  class AssertInstanceOfTest < BasicTest

    setup do
      @test = Assert::Test.new("assert instance of test", lambda do
        assert_instance_of(String, "object")  # pass
        assert_instance_of(Array, "object")   # fail
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

    class MessagesTest < AssertInstanceOfTest

      setup do
        args = [ Array, "object", "assert instance of shouldn't fail!" ]
        @test = Assert::Test.new("assert instance of message test", lambda do
          assert_instance_of(*args)
        end, @context_klass)
        @expected_message = "Expected #{args[1].inspect} to be an instance of #{args[0]}, not #{args[1].class}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertNotInstanceOfTest < BasicTest

    setup do
      @test = Assert::Test.new("assert not instance of test", lambda do
        assert_not_instance_of(String, "object")  # fail
        assert_not_instance_of(Array, "object")   # pass
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

    class MessagesTest < AssertNotInstanceOfTest

      setup do
        args = [ String, "object", "assert not instance of shouldn't fail!" ]
        @test = Assert::Test.new("assert not instance of message test", lambda do
          assert_not_instance_of(*args)
        end, @context_klass)
        @expected_message = "#{args[1].inspect} was not expected to be an instance of #{args[0]}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end



  class AssertRespondToTest < BasicTest

    setup do
      @test = Assert::Test.new("assert respond to test", lambda do
        assert_respond_to(1, :abs)      # pass
        assert_respond_to("1", :abs)    # fail
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

    class MessagesTest < AssertRespondToTest

      setup do
        args = [ "1", :abs, "assert respond to shouldn't fail!" ]
        @test = Assert::Test.new("assert respond to message test", lambda do
          assert_respond_to(*args)
        end, @context_klass)
        @expected_message = "Expected #{args[0].inspect} (#{args[0].class}) to respond to ##{args[1]}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertNotRespondToTest < BasicTest

    setup do
      @test = Assert::Test.new("assert not respond to test", lambda do
        assert_not_respond_to(1, :abs)     # fail
        assert_not_respond_to("1", :abs)   # pass
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

    class MessagesTest < AssertNotRespondToTest

      setup do
        args = [ 1, :abs, "assert not respond to shouldn't fail!" ]
        @test = Assert::Test.new("assert not respond to message test", lambda do
          assert_not_respond_to(*args)
        end, @context_klass)
        @expected_message = "#{args[0].inspect} (#{args[0].class}) not expected to respond to ##{args[1]}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertSameTest < BasicTest

    setup do
      klass = Class.new
      object = klass.new
      @test = Assert::Test.new("assert same test", lambda do
        assert_same(object, object)     # pass
        assert_same(object, klass.new)  # fail
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

    class MessagesTest < AssertSameTest

      setup do
        klass = Class.new
        args = [ klass.new, klass.new, "assert same shoudn't fail!" ]
        @test = Assert::Test.new("assert same message test", lambda do
          assert_same(*args)
        end, @context_klass)
        @expected_message = "Expected #{args[0].inspect} (#{args[0].object_id}) to be the same as #{args[1]} (#{args[1].object_id}).\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertNotSameTest < BasicTest

    setup do
      klass = Class.new
      object = klass.new
      @test = Assert::Test.new("assert not same test", lambda do
        assert_not_same(object, object)     # fail
        assert_not_same(object, klass.new)  # pass
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

    class MessagesTest < AssertNotSameTest

      setup do
        klass = Class.new
        object = klass.new
        args = [ object, object, "assert not same shoudn't fail!" ]
        @test = Assert::Test.new("assert not same message test", lambda do
          assert_not_same(*args)
        end, @context_klass)
        @expected_message = "#{args[0].inspect} (#{args[0].object_id}) not expected to be the same as #{args[1]} (#{args[1].object_id}).\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end



  class AssertEqualTest < BasicTest

    setup do
      @test = Assert::Test.new("assert equal test", lambda do
        assert_equal(1, 1)  # pass
        assert_equal(1, 2)  # fail
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

    class MessagesTest < AssertEqualTest

      setup do
        args = [ 1, 2, "assert equal shoudn't fail!" ]
        @test = Assert::Test.new("assert equal message test", lambda do
          assert_equal(*args)
        end, @context_klass)
        @expected_message = "Expected #{args[0].inspect}, not #{args[1].inspect}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertNotEqualTest < BasicTest

    setup do
      @test = Assert::Test.new("assert not equal test", lambda do
        assert_not_equal(1, 1)  # fail
        assert_not_equal(1, 2)  # pass
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

    class MessagesTest < AssertNotEqualTest

      setup do
        args = [ 1, 1, "assert not equal shoudn't fail!" ]
        @test = Assert::Test.new("assert not equal message test", lambda do
          assert_not_equal(*args)
        end, @context_klass)
        @expected_message = "#{args[0].inspect} not expected to be equal to #{args[1].inspect}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end



  class AssertMatchTest < BasicTest

    setup do
      @test = Assert::Test.new("assert match test", lambda do
        assert_match("a string", /a/)     # pass
        assert_match("a string", "not")   # fail
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

    class MessagesTest < AssertMatchTest

      setup do
        args = [ "a string", "not", "assert match shoudn't fail!" ]
        @test = Assert::Test.new("assert match message test", lambda do
          assert_match(*args)
        end, @context_klass)
        @expected_message = "Expected #{args[0].inspect} to match #{args[1].inspect}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertNotMatchTest < BasicTest

    setup do
      @test = Assert::Test.new("assert not match test", lambda do
        assert_not_match("a string", /a/)     # fail
        assert_not_match("a string", "not")   # pass
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

    class MessagesTest < AssertNotMatchTest

      setup do
        args = [ "a string", /a/, "assert not match shoudn't fail!" ]
        @test = Assert::Test.new("assert not match message test", lambda do
          assert_not_match(*args)
        end, @context_klass)
        @expected_message = "#{args[0].inspect} not expected to match #{args[1].inspect}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

end
