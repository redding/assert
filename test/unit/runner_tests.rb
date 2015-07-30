require 'assert'
require 'assert/suite'
require 'assert/view'
require 'assert/runner'

class Assert::Runner

  class UnitTests < Assert::Context
    desc "Assert::Runner"
    setup do
      @config = Factory.modes_off_config
      @suite  = Assert::Suite.new(@config)
      @view   = Assert::View::Base.new(StringIO.new("", "w+"), @suite)
      @runner = Assert::Runner.new(@config)
    end
    subject { @runner }

    should have_readers :config
    should have_imeths :run

    should "know its config" do
      assert_equal @config, subject.config
    end

    should "return an integer exit code" do
      assert_equal 0, subject.run(@suite, @view)
    end

  end

end
