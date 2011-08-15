require 'assert'

class Assert::Assertions::BasicTest < Assert::Context

  desc "An assert context"
  setup do
    @context_class = Factory.context_class
    @context = @context_class.new
  end
  subject{ @context }

  INSTANCE_METHODS = [
    :assert_block, :assert_not_block, :refute_block,
    :assert_raises, :assert_raise, :assert_nothing_raised, :assert_not_raises, :assert_not_raise,
    :assert_kind_of, :assert_not_kind_of, :refute_kind_of,
    :assert_instance_of, :assert_not_instance_of, :refute_instance_of,
    :assert_respond_to, :assert_not_respond_to, :refute_respond_to,
    :assert_same, :assert_not_same, :refute_same,
    :assert_equal, :assert_not_equal, :refute_equal,
    :assert_match, :assert_not_match, :assert_no_match, :refute_match
  ]
  INSTANCE_METHODS.each do |method|
    should "respond to the instance method ##{method}" do
      assert_respond_to subject, method
    end
  end

  class IgnoredTest < BasicTest
    desc "ignored assertions helpers"
    setup do
      @tests = Assert::Assertions::IGNORED_ASSERTION_HELPERS.collect do |helper|
        Factory.test("ignored assertion helper #{helper}", @context_class) do
          self.send(helper, "doesn't matter")
        end
      end
      @expected_messages = Assert::Assertions::IGNORED_ASSERTION_HELPERS.collect do |helper|
        [ "The assertion helper '#{helper}' is not supported. Please use ",
          "another helper or the basic assert."
        ].join
      end
      @results = @tests.collect(&:run).flatten
    end
    subject{ @results }

    should "have an ignored result for each helper in the constant" do
      subject.each do |result|
        assert_kind_of Assert::Result::Ignore, result
      end
      assert_equal(Assert::Assertions::IGNORED_ASSERTION_HELPERS.size, subject.size)
    end
    should "have a custom ignore message for each helper in the constant" do
      assert_equal(@expected_messages, subject.collect(&:message))
    end

  end

end
