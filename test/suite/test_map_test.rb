require 'assert'

require 'assert/suite/context_info'
require 'assert/suite/test_map'

class Assert::Suite::TestMap

  class BasicTests < Assert::Context
    desc "the test map used by the suite"
    setup do
      @caller = caller
      @klass = Assert::Context
      @context_info = Assert::Suite::ContextInfo.new(@klass, @caller)
      @map = Assert::Suite::TestMap.new
    end
    subject { @map }

    should have_instance_method :<<, :context_info

    should "not have context info for test names that haven't been mapped" do
      assert_nil @map.context_info(@klass, 'test: has not been mapped')
    end

    should "map a test name to context info" do
      @map.context(@klass, @caller)
      @map << 'test: should do something'

      mapped_context_info = @map.context_info(@klass, 'test: should do something')

      assert_kind_of Assert::Suite::ContextInfo, mapped_context_info
      assert_equal @context_info.klass, mapped_context_info.klass
      assert_equal @context_info.file, mapped_context_info.file
    end

  end

end
