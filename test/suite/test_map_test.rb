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

    should have_accessor :caller_info
    should have_instance_methods :map, :context_info

    should "map a test name to context info" do
      @map.caller_info = @caller
      @map.map(@klass, 'test: should do something')

      mapped_context_info = @map.context_info(@klass, 'test: should do something')

      assert_kind_of Assert::Suite::ContextInfo, mapped_context_info
      assert_equal @context_info.klass, mapped_context_info.klass
      assert_equal @context_info.file, mapped_context_info.file
    end

    should "return context info w/ just the klass if no mapped info found" do
      klass_only_context_info = Assert::Suite::ContextInfo.new(@klass)
      mapped_context_info = @map.context_info(@klass, 'test: has not been mapped')

      assert_kind_of Assert::Suite::ContextInfo, mapped_context_info
      assert_equal klass_only_context_info.klass, mapped_context_info.klass
      assert_equal klass_only_context_info.file, mapped_context_info.file
    end

  end

end
