require 'assert'
require 'assert/default_runner'

require 'assert/runner'

class Assert::DefaultRunner

  class UnitTests < Assert::Context
    desc "Assert::DefaultRunner"
    setup do
      @config = Factory.modes_off_config
      @runner = Assert::DefaultRunner.new(@config)
    end
    subject{ @runner }

    should have_imeths :on_start, :run!

    should "descibe the run on start" do
      output = ""
      view   = Assert::View.new(@config, StringIO.new(output, "w+"))
      Assert.stub(subject, :view){ view }

      subject.on_start
      assert_empty output

      ci = Factory.context_info(Factory.modes_off_context_class)
      @config.suite.tests << Factory.test("should pass", ci){ assert(1==1) }
      subject.on_start

      exp = "Running tests in random order, seeded with \"#{subject.runner_seed}\"\n"
      assert_equal exp, output
    end

  end

end
