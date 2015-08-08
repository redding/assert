require 'assert'
require 'assert/context/suite_dsl'

require 'assert/suite'

module Assert::Context::SuiteDSL

  class UnitTests < Assert::Context
    desc "Assert::Context::SuiteDSL"
    setup do
      @custom_suite = Factory.modes_off_suite
      @context_class = Factory.context_class
    end
    subject{ @context_class }

    should "use `Assert.suite` by default" do
      assert_equal Assert.suite, subject.suite
    end

    should "use any given custom suite" do
      subject.suite(@custom_suite)
      assert_equal @custom_suite, subject.suite
    end

  end

  class SuiteFromParentTests < UnitTests
    desc "`suite` method using parent context"
    setup do
      @parent_class = Factory.context_class
      @parent_class.suite(@custom_suite)
      @context_class = Factory.context_class(@parent_class)
    end

    should "default to it's parent's suite" do
      assert_equal @custom_suite, subject.suite
    end

    should "use any given custom suite" do
      another_suite = Factory.modes_off_suite
      subject.suite(another_suite)
      assert_equal another_suite, subject.suite
    end

  end

end
