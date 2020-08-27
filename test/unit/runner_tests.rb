require "assert"
require "assert/runner"

require "stringio"
require "assert/config_helpers"
require "assert/default_suite"
require "assert/result"
require "assert/view"

class Assert::Runner
  class UnitTests < Assert::Context
    desc "Assert::Runner"
    subject { Assert::Runner }

    should "include the config helpers" do
      assert_includes Assert::ConfigHelpers, subject
    end
  end

  class InitTests < UnitTests
    desc "when init"
    subject { runner1 }

    setup do
      config1.suite Assert::DefaultSuite.new(config1)
      config1.view  Assert::View.new(config1, StringIO.new("", "w+"))
    end

    let(:config1) { Factory.modes_off_config }
    let(:runner1) { Assert::Runner.new(config1) }

    should have_readers :config
    should have_imeths :runner, :run
    should have_imeths :before_load, :after_load
    should have_imeths :on_start, :on_finish, :on_info, :on_interrupt
    should have_imeths :before_test, :after_test, :on_result

    should "know its config" do
      assert_equal config1, subject.config
    end

    should "override the config helper's runner value with itself" do
      assert_equal subject, subject.runner
    end
  end

  class RunTests < InitTests
    desc "and run"

    setup do
      @view_output = ""

      suite_class = Class.new(Assert::DefaultSuite){ include CallbackMixin }
      view_class  = Class.new(Assert::View){ include CallbackMixin }

      config1.suite suite_class.new(config1)
      config1.view  view_class.new(config1, StringIO.new(@view_output, "w+"))
      config1.suite.on_test(test1)

      @result = subject.run
    end

    let(:runner_class1) { Class.new(Assert::Runner) { include CallbackMixin } }
    let(:ci1) { Factory.context_info(Factory.modes_off_context_class) }
    let(:test1) { Factory.test("should pass", ci1){ assert(1==1) } }
    let(:runner1) { runner_class1.new(config1) }

    should "return the fail+error result count as an integer exit code" do
      assert_equal 0, @result

      fail_count  = Factory.integer
      error_count = Factory.integer
      Assert.stub(subject, :fail_result_count){ fail_count }
      Assert.stub(subject, :error_result_count){ error_count }
      Assert.stub(test1, :run){ } # no-op
      result = runner1.run

      exp = fail_count + error_count
      assert_equal exp, result
    end

    should "run all callbacks on itself, the suite and the view" do
      # itself
      assert_true subject.on_start_called
      assert_equal [test1], subject.before_test_called
      assert_instance_of Assert::Result::Pass, subject.on_result_called.last
      assert_equal [test1], subject.after_test_called
      assert_true subject.on_finish_called

      # suite
      suite = config1.suite
      assert_true suite.on_start_called
      assert_equal [test1], suite.before_test_called
      assert_instance_of Assert::Result::Pass, suite.on_result_called.last
      assert_equal [test1], suite.after_test_called
      assert_true suite.on_finish_called

      # view
      view = config1.view
      assert_true view.on_start_called
      assert_equal [test1], view.before_test_called
      assert_instance_of Assert::Result::Pass, view.on_result_called.last
      assert_equal [test1], view.after_test_called
      assert_true view.on_finish_called
    end

    should "describe running the tests in random order if there are tests" do
      exp = "Running tests in random order, " \
            "seeded with \"#{subject.runner_seed}\"\n"
      assert_includes exp, @view_output

      @view_output.gsub!(/./, "")
      config1.suite.clear_tests_to_run
      subject.run
      assert_not_includes exp, @view_output
    end

    should "run only a single test if a single test is configured" do
      test = Factory.test("should pass", ci1){ assert(1==1) }
      config1.suite.clear_tests_to_run
      config1.suite.on_test(test)
      config1.single_test test.file_line.to_s

      runner = runner_class1.new(config1).tap(&:run)
      assert_equal [test], runner.before_test_called
    end

    should "not run any tests if a single test is configured but can't be found" do
      test = Factory.test("should pass", ci1){ assert(1==1) }
      config1.suite.clear_tests_to_run
      config1.suite.on_test(test)
      config1.single_test Factory.string

      runner = runner_class1.new(config1).tap(&:run)
      assert_nil runner.before_test_called
    end

    should "describe running only a single test if a single test is configured" do
      config1.suite.clear_tests_to_run
      config1.suite.on_test(test1)
      config1.single_test test1.file_line.to_s
      @view_output.gsub!(/./, "")
      subject.run

      exp = "Running test: #{subject.single_test_file_line}, " \
            "seeded with \"#{subject.runner_seed}\"\n"
      assert_includes exp, @view_output
    end
  end

  module CallbackMixin
    attr_reader :on_start_called, :on_finish_called
    attr_reader :before_test_called, :after_test_called, :on_result_called

    def on_start
      @on_start_called = true
    end

    def before_test(test)
      @before_test_called ||= []
      @before_test_called << test
    end

    def on_result(result)
      @on_result_called ||= []
      @on_result_called << result
    end

    def after_test(test)
      @after_test_called ||= []
      @after_test_called << test
    end

    def on_finish
      @on_finish_called = true
    end
  end
end
