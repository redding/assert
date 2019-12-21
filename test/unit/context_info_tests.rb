require "assert"
require "assert/context_info"

require "assert/context"

class Assert::ContextInfo
  class UnitTests < Assert::Context
    desc "Assert::ContextInfo"
    setup do
      @caller = caller
      @klass  = Assert::Context
      @info   = Assert::ContextInfo.new(@klass, nil, @caller.first)
    end
    subject{ @info }

    should have_readers :called_from, :klass, :file
    should have_imeths :test_name

    should "set its klass on init" do
      assert_equal @klass, subject.klass
    end

    should "set its called_from to the called_from or first caller on init" do
      info = Assert::ContextInfo.new(@klass, @caller.first, nil)
      assert_equal @caller.first, info.called_from

      info = Assert::ContextInfo.new(@klass, nil, @caller.first)
      assert_equal @caller.first, info.called_from
    end

    should "set its file from caller info on init" do
      assert_equal @caller.first.gsub(/\:[0-9]+.*$/, ""), subject.file
    end

    should "not have any file info if no caller is given" do
      info = Assert::ContextInfo.new(@klass)
      assert_nil info.file
    end

    should "know how to build the contextual test name for a given name" do
      desc = Factory.string
      name = Factory.string

      assert_equal name, subject.test_name(name)
      assert_equal "",   subject.test_name("")
      assert_equal "",   subject.test_name(nil)

      Assert.stub(subject.klass, :description){ desc }
      assert_equal "#{desc} #{name}", subject.test_name(name)
    end
  end
end
