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
      reset_run_data
    end

    def before_load(test_files)
    end

    def after_load
      puts "Loaded suite (#{tests_to_run_count_statement})"
    end

    def on_start
      reset_run_data
    end

    def before_test(test)
      if accumulate_test_data?
        test_data = get_test_data(test)
        puts  "#{test_data.name.inspect} (#{test_data.context})"
        puts  "    #{test_data.file_line}"
        print "    "
      end
    end

    def on_result(result)
      print ansi_styled_msg(self.send("#{result.to_sym}_abbrev"), result.type)
      @results_to_dump << ResultData.for_result(result) if dumpable_result?(result)
      if accumulate_test_data?
        find_test_data(result.test_file_line).result_count += 1
      end
    end

    def after_test(test)
      if accumulate_test_data?
        test_data = find_test_data(test.file_line)
        test_data.run_time    = test.run_time
        test_data.result_rate = get_rate(test_data.result_count, test_data.run_time)

        if show_test_verbose_info?
          print " #{formatted_run_time(test_data.run_time)} seconds,"\
                " #{test_data.result_count} results,"\
                " #{formatted_result_rate(test_data.result_rate)} results/s\n"
        end
      end
    end

    def on_finish
      if self.test_count > 0
        dump_test_results
      end

      # show profile output
      if show_test_profile_info?
        # sort the test datas fastest to slowest
        @test_datas.values.sort{ |a, b| a.run_time <=> b.run_time }.each do |test_data|
          puts "#{formatted_run_time(test_data.run_time)} seconds,"\
               " #{test_data.result_count} results,"\
               " #{formatted_result_rate(test_data.result_rate)} results/s --"\
               " #{test_data.context}: #{test_data.name.inspect}"
        end
        puts
      end

      # style the summaries of each result set
      styled_results_sentence = results_summary_sentence do |summary, result_type|
        ansi_styled_msg(summary, result_type)
      end

      puts "#{result_count_statement}: #{styled_results_sentence}"
      puts
      puts "(#{formatted_suite_run_time} seconds, " \
           "#{formatted_suite_test_rate} tests/s, " \
           "#{formatted_suite_result_rate} results/s)"
    end

    def on_interrupt(err)
      dump_test_results
    end

    private

    def accumulate_test_data?
      show_test_verbose_info? || show_test_profile_info?
    end

    def get_test_data(test)
      @test_datas[test.file_line.to_s] ||= TestData.for_test(test)
    end

    def find_test_data(test_file_line)
      @test_datas[test_file_line.to_s]
    end

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

    def reset_run_data
      @results_to_dump = []
      @test_datas      = {}
    end

    attrs = [:name, :context, :file_line, :result_count, :run_time, :result_rate]
    class TestData < Struct.new(*attrs)
      def self.for_test(t)
        self.new(t.name, t.context_class, t.file_line.to_s, 0, 0.0, 0.0)
      end
    end

    attrs = [:type, :details, :output, :file_name, :line_num, :test_id]
    class ResultData < Struct.new(*attrs)
      def self.for_result(r)
        self.new(r.type, r.to_s, r.output, r.file_name, r.line_num, r.test_id)
      end

      def file_name_and_line_num
        [self.file_name, self.line_num]
      end

      def <=>(other_rd)
        # show in reverse definition order
        if other_rd.kind_of?(ResultData)
          other_rd.file_name_and_line_num <=> self.file_name_and_line_num
        else
          super
        end
      end
    end

  end

end
