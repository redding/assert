require 'assert/view'
require 'assert/view_helpers'

module Assert

  # This is the default view used by assert.  It renders ansi test output
  # designed for terminal viewing.

  class DefaultView < Assert::View
    include Assert::ViewHelpers::Ansi

    # setup options and their default values

    option 'styled',        true
    option 'pass_styles',   :green
    option 'fail_styles',   :red, :bold
    option 'error_styles',  :yellow, :bold
    option 'skip_styles',   :cyan
    option 'ignore_styles', :magenta

    def initialize(*args)
      super
      @results_to_dump = []
    end

    def before_load(test_files)
    end

    def after_load
      puts "Loaded suite (#{tests_to_run_count_statement})"
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
      print ansi_styled_msg(self.send("#{result.to_sym}_abbrev"), result.type)
      @results_to_dump << ResultData.for_result(result) if dumpable_result?(result)
    end

    def after_test(test)
      if show_test_verbose_info?
        print " #{test_run_time(test)} seconds,"\
              " #{test.result_count} results,"\
              " #{test_result_rate(test)} results/s\n"
      end
    end

    def on_finish
      if self.test_count > 0
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
      styled_results_sentence = results_summary_sentence do |summary, result_type|
        ansi_styled_msg(summary, result_type)
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

    def dumpable_result?(result)
      [:fail, :error].include?(result.type) ||
      !!([:skip, :ignore].include?(result.type) && result.message)
    end

    def dump_test_results
      print "\n"
      puts

      @results_to_dump.sort.each do |result_data|
        # output the styled result details
        puts ansi_styled_msg(result_data.details, result_data.type)

        # output any captured stdout
        if result_data.output && !result_data.output.empty?
          puts captured_output(result_data.output)
        end

        # output re-run CLI cmd
        puts re_run_test_cmd(result_data.test_id)

        # add an empty line between each dumped result
        puts
      end
    end

    class ResultData < Struct.new(:type, :details, :output, :file_line, :test_id)
      def self.for_result(r)
        self.new(r.type, r.to_s, r.output, r.file_line, r.test_id)
      end

      def <=>(other_result_data)
        # show in reverse definition order
        if other_result_data.kind_of?(ResultData)
          other_result_data.file_line <=> self.file_line
        else
          super
        end
      end
    end

  end

end
