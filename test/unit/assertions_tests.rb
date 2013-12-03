require 'assert'
require 'assert/assertions'

module Assert::Assertions

  class UnitTests < Assert::Context
    desc "An assert context"
    setup do
      @context_class = Factory.context_class
      @test = Factory.test
      @context = @context_class.new(@test, @test.config)
    end
    subject{ @context }

    should have_imeths :assert_block, :assert_not_block, :refute_block
    should have_imeths :assert_raises, :assert_not_raises
    should have_imeths :assert_raise, :assert_not_raise, :assert_nothing_raised
    should have_imeths :assert_kind_of, :assert_not_kind_of, :refute_kind_of
    should have_imeths :assert_instance_of, :assert_not_instance_of, :refute_instance_of
    should have_imeths :assert_respond_to, :assert_responds_to
    should have_imeths :assert_not_respond_to, :assert_not_responds_to
    should have_imeths :refute_respond_to, :refute_responds_to
    should have_imeths :assert_same, :assert_not_same, :refute_same
    should have_imeths :assert_equal, :assert_not_equal, :refute_equal
    should have_imeths :assert_match, :assert_not_match, :assert_no_match, :refute_match
    should have_imeths :assert_empty, :assert_not_empty, :refute_empty
    should have_imeths :assert_includes, :assert_not_includes
    should have_imeths :assert_included, :assert_not_included
    should have_imeths :refute_includes, :refute_included
    should have_imeths :assert_nil, :assert_not_nil, :refute_nil
    should have_imeths :assert_file_exists, :assert_not_file_exists, :refute_file_exists

  end

  class IgnoredTests < UnitTests
    desc "ignored assertions helpers"
    setup do
      @tests = Assert::Assertions::IGNORED_ASSERTION_HELPERS.map do |helper|
        context_info = Factory.context_info(@context_class)
        Factory.test("ignored assertion helper #{helper}", context_info) do
          self.send(helper, "doesn't matter")
        end
      end
      @expected_messages = Assert::Assertions::IGNORED_ASSERTION_HELPERS.map do |helper|
        "The assertion `#{helper}` is not supported."\
        " Please use another assertion or the basic `assert`."
      end
      @results = @tests.map(&:run).flatten
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
