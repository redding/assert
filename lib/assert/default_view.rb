require 'assert/view'

module Assert

  # This is the default view used by assert.  It renders ansi test output
  # designed for terminal viewing.

  class DefaultView < Assert::View

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
    end

    def before_test(test)
      if show_test_verbose_info?
        puts  "#{test.name.inspect} (#{test.context_class})"
        puts  "    #{test.file_line}"
        print "    "
      end
    end

    def on_result(result)
      print ansi_styled_msg(self.send("#{result.to_sym}_abbrev"), result)
    end

    def after_test(test)
      if show_test_verbose_info?
        print " #{test_run_time(test)} seconds,"\
              " #{test.result_count} results,"\
              " #{test_result_rate(test)} results/s\n"
      end
    end

    def on_finish
      if tests?
        dump_test_results
      end

      # show profile output
      if show_test_profile_info?
        config.suite.ordered_tests_by_run_time.each do |test|
          puts "#{test_run_time(test)} seconds,"\
               " #{test.result_count} results,"\
               " #{test_result_rate(test)} results/s --"\
               " #{test.context_class}: #{test.name.inspect}"
        end
        puts
      end

      # style the summaries of each result set
      styled_results_sentence = results_summary_sentence do |summary, result_sym|
        ansi_styled_msg(summary, result_sym)
      end

      puts "#{result_count_statement}: #{styled_results_sentence}"
      puts
      puts "(#{formatted_run_time} seconds, " \
           "#{formatted_test_rate} tests/s, " \
           "#{formatted_result_rate} results/s)"
    end

    def on_interrupt(err)
      dump_test_results
    end

    private

    def dump_test_results
      print "\n"
      puts

      config.suite.reversed_results_for_dump.each do |result|
        # output the styled result details
        puts ansi_styled_msg(result.to_s, result)

        # output any captured stdout
        puts captured_output(result.output) if result.output && !result.output.empty?

        # add an empty line between each result detail
        puts
      end

    end

  end

end
