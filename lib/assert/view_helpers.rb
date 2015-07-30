require 'assert/config_helpers'

module Assert

  module ViewHelpers

    def self.included(receiver)
      receiver.class_eval do
        include Assert::ConfigHelpers
        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods

      def option(name, *default_vals)
        default = default_vals.size > 1 ? default_vals : default_vals.first
        define_method(name) do |*args|
          if !(value = args.size > 1 ? args : args.first).nil?
            instance_variable_set("@#{name}", value)
          end
          (val = instance_variable_get("@#{name}")).nil? ? default : val
        end
      end

    end

    module InstanceMethods

      # get the formatted run time for an idividual test
      def test_run_time(test, format = '%.6f')
        format % test.run_time
      end

      # get the formatted result rate for an individual test
      def test_result_rate(test, format = '%.6f')
        format % test.result_rate
      end

      # get all the result details for a set of tests
      def result_details_for(tests, result_order = :normal)
        test_index = 0
        tests.collect do |test|
          test_index += 1

          details = test.results.collect do |result|
            ResultDetails.new(result, test, test_index)
          end
          details.reverse! if result_order == :reversed
          details
        end.compact.flatten
      end

      # get all the result details for a set of tests matching a file or context
      def matched_result_details_for(match, tests, result_order = :normal)
        context_match = match.kind_of?(Class) && match.ancestors.include?(Assert::Context)
        file_match = match.kind_of?(String)

        matching_tests = if context_match
          tests.select {|test| test.context_info.klass == match}
        elsif file_match
          tests.select {|test| test.context_info.file == match}
        else
          tests
        end

        result_details_for(matching_tests, result_order)
      end

      # only show result details for failed or errored results
      # show result details if a skip or passed result was issues w/ a message
      def show_result_details?(result)
        [:fail, :error].include?(result.to_sym) ||
        !!([:skip, :ignore].include?(result.to_sym) && result.message)
      end

      # show any captured output
      def captured_output(output)
        "--- stdout ---\n"\
        "#{output}"\
        "--------------"
      end

      def test_count_statement
        "#{self.count(:tests)} test#{'s' if self.count(:tests) != 1}"
      end

      def result_count_statement
        "#{self.count(:results)} result#{'s' if self.count(:results) != 1}"
      end

      # generate a comma-seperated sentence fragment given a list of items
      def to_sentence(items)
        if items.size <= 2
          items.join(items.size == 2 ? ' and ' : '')
        else
          [items[0..-2].join(", "), items.last].join(", and ")
        end
      end

      # generate an appropriate result summary msg for all tests passing
      def all_pass_result_summary_msg
        if self.count(:results) < 1
          "uhh..."
        elsif self.count(:results) == 1
          "pass"
        else
          "all pass"
        end
      end

      # print a result summary message for a given result type
      def result_summary_msg(result_type)
        if result_type == :pass && self.all_pass?
          self.all_pass_result_summary_msg
        else
          "#{self.count(result_type)} #{result_type.to_s}"
        end
      end

      # generate a sentence fragment describing the breakdown of test results
      # if a block is given, yield each msg in the breakdown for custom formatting
      def results_summary_sentence
        summaries = self.ocurring_result_types.map do |result_sym|
          summary_msg = self.result_summary_msg(result_sym)
          block_given? ? yield(summary_msg, result_sym) : summary_msg
        end
        self.to_sentence(summaries)
      end

    end

    class ResultDetails

      attr_reader :result, :test_index, :test, :output

      def initialize(result, test, test_index)
        @result     = result
        @test       = test
        @test_index = test_index
        @output     = test.output
      end

    end

  end

end
