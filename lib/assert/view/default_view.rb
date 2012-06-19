require 'assert/view/base'
require 'assert/view/helpers/ansi_styles'
require 'assert/view/helpers/capture_output'

module Assert::View

  # This is the default view used by assert.  It renders ansi test output
  # designed for terminal viewing.

  class DefaultView < Base
    helper Helpers::CaptureOutput
    helper Helpers::AnsiStyles

    options do
      styled         true
      pass_styles    :green
      fail_styles    :red, :bold
      error_styles   :yellow, :bold
      skip_styles    :cyan
      ignore_styles  :magenta
    end

    template do
      _ "Loaded suite (#{view.test_count_statement})"

      if view.tests?
        _ "Running tests in random order, seeded with \"#{view.runner_seed}\""

        view.run_tests(runner) do |result|
          result_abbrev = view.options.send("#{result.to_sym}_abbrev")
          styled_abbrev = ansi_styled_msg(result_abbrev, result_ansi_styles(result))

          # list out an abbrev for each test result as it is run
          _ styled_abbrev, false
        end
        _ "\n", false  # add a newline after list of test result abbrevs
        _

        # output detailed results for the tests in reverse test/result order
        tests = view.suite.ordered_tests.reverse
        view.result_details_for(tests, :reversed).each do |details|
          # output the styled result details
          result = details.result
          _ ansi_styled_msg(result.to_s, result_ansi_styles(result))

          # output any captured output
          output = details.output
          _ captured_output(output) if output && !output.empty?
          _
        end
      end

      styled_results_sentence = view.results_summary_sentence do |summary, sym|
        # style the summaries of each result set
        ansi_styled_msg(summary, result_ansi_styles(sym))
      end

      _ "#{view.result_count_statement}: #{styled_results_sentence}"
      _
      _ "(#{view.run_time} seconds)"
    end

  end

end
