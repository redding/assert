require "assert"
require "assert/view_helpers"

require "stringio"
require "assert/config"
require "assert/config_helpers"
require "assert/result"
require "assert/view"

module Assert::ViewHelpers

  class UnitTests < Assert::Context
    desc "Assert::ViewHelpers"
    setup do
      test_opt_val = @test_opt_val = Factory.string
      @helpers_class = Class.new do
        include Assert::ViewHelpers

        option "test_opt", test_opt_val

        def config
          # use the assert config since it has tests, contexts, etc
          # also maybe use a fresh config that is empty
          @config ||= [Assert.config, Assert::Config.new].sample
        end
      end
    end
    subject{ @helpers_class }

    should have_imeths :option

    should "include the config helpers" do
      assert_includes Assert::ConfigHelpers, subject
    end

    should "write option values" do
      helpers = @helpers_class.new
      assert_equal @test_opt_val, helpers.test_opt

      new_val = Factory.integer
      helpers.test_opt new_val
      assert_equal new_val, helpers.test_opt

      other_val = Factory.integer
      helpers.test_opt new_val, other_val
      assert_equal [new_val, other_val], helpers.test_opt
    end

  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @helpers = @helpers_class.new
    end
    subject{ @helpers }

    should have_imeths :captured_output, :re_run_test_cmd
    should have_imeths :tests_to_run_count_statement, :result_count_statement
    should have_imeths :to_sentence
    should have_imeths :all_pass_result_summary_msg, :result_summary_msg
    should have_imeths :results_summary_sentence

    should "know how to build captured output" do
      output = Factory.string
      exp = "--- stdout ---\n"\
            "#{output}"\
            "--------------"
      assert_equal exp, subject.captured_output(output)
    end

    should "know how to build the re-run test cmd" do
      test_id = "#{Dir.pwd}/#{Factory.string}_tests.rb:#{Factory.integer}"
      exp = "assert -t #{test_id.gsub(Dir.pwd, ".")}"
      assert_equal exp, subject.re_run_test_cmd(test_id)
    end

    should "know its tests-to-run count and result count statements" do
      exp = "#{subject.tests_to_run_count} test#{"s" if subject.tests_to_run_count != 1}"
      assert_equal exp, subject.tests_to_run_count_statement

      exp = "#{subject.result_count} result#{"s" if subject.result_count != 1}"
      assert_equal exp, subject.result_count_statement
    end

    should "know how to build a sentence from a list of items" do
      items = 1.times.map{ Factory.string }
      assert_equal items.first, subject.to_sentence(items)

      items = 2.times.map{ Factory.string }
      assert_equal items.join(" and "), subject.to_sentence(items)

      items = (Factory.integer(3)+2).times.map{ Factory.string }
      exp = [items[0..-2].join(", "), items.last].join(", and ")
      assert_equal exp, subject.to_sentence(items)
    end

    should "know its all pass result summary message" do
      Assert.stub(subject, :result_count){ 0 }
      assert_equal "uhh...", subject.all_pass_result_summary_msg

      Assert.stub(subject, :result_count){ 1 }
      assert_equal "pass", subject.all_pass_result_summary_msg

      Assert.stub(subject, :result_count){ Factory.integer(10)+1 }
      assert_equal "all pass", subject.all_pass_result_summary_msg
    end

    should "know its result summary msg" do
      res_type = :pass
      Assert.stub(subject, :all_pass?){ true }
      exp = subject.all_pass_result_summary_msg
      assert_equal exp, subject.result_summary_msg(res_type)

      Assert.stub(subject, :all_pass?){ false }
      res_type = [:pass, :ignore, :fail, :skip, :error].sample
      exp = "#{subject.send("#{res_type}_result_count")} #{res_type.to_s}"
      assert_equal exp, subject.result_summary_msg(res_type)
    end

    should "know its results summary sentence" do
      items = subject.ocurring_result_types.map do |result_sym|
        subject.result_summary_msg(result_sym)
      end
      exp = subject.to_sentence(items)
      assert_equal exp, subject.results_summary_sentence

      block = proc{ |summary, result| "#{summary}--#{result}" }
      items = subject.ocurring_result_types.map do |result_sym|
        block.call(subject.result_summary_msg(result_sym), result_sym)
      end
      exp = subject.to_sentence(items)
      assert_equal exp, subject.results_summary_sentence(&block)
    end

  end

  class AnsiTests < UnitTests
    desc "Ansi"
    subject{ Ansi }

    should have_imeths :code_for

    should "know its codes" do
      assert_not_empty subject::CODES
    end

    should "map its code style names to ansi code strings" do
      styles = Factory.integer(3).times.map{ subject::CODES.keys.sample }
      exp = styles.map{ |n| "\e[#{subject::CODES[n]}m" }.join("")
      assert_equal exp, subject.code_for(*styles)

      styles = Factory.integer(3).times.map{ Factory.string }
      assert_equal "", subject.code_for(*styles)

      styles = []
      assert_equal "", subject.code_for(*styles)
    end

  end

  class AnsiInitTests < UnitTests
    desc "when mixed in on a view"
    setup do
      view_class = Class.new(Assert::View){ include Ansi }
      @view = view_class.new(Factory.modes_off_config, StringIO.new("", "w+"))
    end
    subject{ @view }

    should have_imeths :ansi_styled_msg

    should "know how to build ansi styled messages" do
      msg = Factory.string
      result_type = [:pass, :fail, :error, :skip, :ignore].sample

      Assert.stub(subject, :is_tty?){ false }
      Assert.stub(subject, :styled){ false }
      assert_equal msg, subject.ansi_styled_msg(msg, result_type)

      Assert.stub(subject, :is_tty?){ false }
      Assert.stub(subject, :styled){ true }
      assert_equal msg, subject.ansi_styled_msg(msg, result_type)

      Assert.stub(subject, :is_tty?){ true }
      Assert.stub(subject, :styled){ false }
      assert_equal msg, subject.ansi_styled_msg(msg, result_type)

      Assert.stub(subject, :is_tty?){ true }
      Assert.stub(subject, :styled){ true }
      Assert.stub(subject, "#{result_type}_styles"){ [] }
      assert_equal msg, subject.ansi_styled_msg(msg, result_type)

      styles = Factory.integer(3).times.map{ Assert::ViewHelpers::Ansi::CODES.keys.sample }
      Assert.stub(subject, "#{result_type}_styles"){ styles }
      exp_code = Assert::ViewHelpers::Ansi.code_for(*styles)
      exp = exp_code + msg + Assert::ViewHelpers::Ansi.code_for(:reset)
      assert_equal exp, subject.ansi_styled_msg(msg, result_type)
    end

  end

end
