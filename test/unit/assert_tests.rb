require 'assert'

require 'assert/config'

module Assert

  class UnitTests < Assert::Context
    desc "Assert"
    subject { Assert }

    should have_imeths :config, :configure, :view, :suite, :runner

    should "know its config instance" do
      assert_kind_of Assert::Config, subject.config
    end

    should "map its view, suite and runner to its config" do
      assert_same subject.config.view,   subject.view
      assert_same subject.config.suite,  subject.suite
      assert_same subject.config.runner, subject.runner
    end

    # Note: don't really need to explicitly test the configure method as
    # nothing runs if it isn't working

  end

end
