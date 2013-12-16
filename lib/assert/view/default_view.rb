require 'assert/view/base'

module Assert::View

  # This is the default view used by assert.  It renders ansi test output
  # designed for terminal viewing.

  class DefaultView < Base
    require 'assert/view/helpers/ansi_styles'
    include Helpers::AnsiStyles

    # setup options and their default values

    option 'styled',        true
    option 'pass_styles',   :green
    option 'fail_styles',   :red, :bold
    option 'error_styles',  :yellow, :bold
    option 'skip_styles',   :cyan
    option 'ignore_styles', :magenta

    def before_load(test_files)
    end

    def after_load
      puts "Loaded suite (#{test_count_statement})"
    end

    def on_start
      if tests?
        puts "Running tests in random order, seeded with \"#{runner_seed}\""
      end
    end

    def on_result(result)
      result_abbrev = self.send("#{result.to_sym}_abbrev")
      styled_abbrev = ansi_styled_msg(result_abbrev, result_ansi_styles(result))

      print styled_abbrev
    end

    def on_finish
      if tests?
        print "\n"
        puts

        # output detailed results for the tests in reverse test/result order
        tests = suite.ordered_tests.reverse
        result_details_for(tests, :reversed).each do |details|
          if show_result_details?(details.result)
            # output the styled result details
            result = details.result
            puts ansi_styled_msg(result.to_s, result_ansi_styles(result))

            # output any captured stdout
            output = details.output
            puts captured_output(output) if output && !output.empty?

            # add an empty line between each result detail
            puts
          end
        end
      end

      # style the summaries of each result set
      styled_results_sentence = results_summary_sentence do |summary, sym|
        ansi_styled_msg(summary, result_ansi_styles(sym))
      end

      puts "#{result_count_statement}: #{styled_results_sentence}"
      puts
      puts "(#{run_time} seconds, #{test_rate} tests/s, #{result_rate} results/s)"
    end

  end

end
