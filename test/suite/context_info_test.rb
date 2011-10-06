require 'assert'

require 'assert/suite/context_info'

class Assert::Suite::ContextInfo

  class BasicTests < Assert::Context
    desc "a suite's context info"
    setup do
      @caller = caller
      @klass = Assert::Context
      @info = Assert::Suite::ContextInfo.new(@klass, @caller)
    end
    subject { @info }

    should have_readers :klass, :file

    should "set its klass on init" do
      assert_equal @klass, subject.klass
    end

    should "set its file from caller info on init" do
      assert_equal @caller.first.gsub(/\:[0-9]+$/, ''), subject.file
    end

  end

end
