module Assert::View

  class ResultDetails

    attr_reader :result, :test_index, :test, :output

    def initialize(result, test, test_index)
      @result = result
      @test = test
      @test_index = test_index
      @output = test.output
    end
  end

  module Common

    # get the formatted suite run time
    def run_time(format='%.6f')
      format % self.suite.run_time
    end

    def runner_seed
      self.suite.runner_seed
    end

    def count(type)
      self.suite.count(type)
    end

    def tests?
      self.count(:tests) > 0
    end

    def all_pass?
      self.count(:pass) == self.count(:results)
    end

    # get a uniq list of contexts for the test suite
    def suite_contexts
      @suite_contexts ||= self.suite.tests.inject([]) do |contexts, test|
        contexts << test.context_info.klass
      end.uniq
    end

    def ordered_suite_contexts
      self.suite_contexts.sort{|a,b| a.to_s <=> b.to_s}
    end

    # get a uniq list of files containing contexts for the test suite
    def suite_files
      @suite_files ||= self.suite.tests.inject([]) do |files, test|
        files << test.context_info.file
      end.uniq
    end

    def ordered_suite_files
      self.suite_files.sort{|a,b| a.to_s <=> b.to_s}
    end

    # get all the result details for a set of tests
    def result_details_for(tests, result_order=:normal)
      test_index = 0
      tests.collect do |test|
        test_index += 1

        details = test.results.
          select { |result| self.show_result_details?(result) }.
          collect { |result| ResultDetails.new(result, test, test_index) }

        details.reverse! if result_order == :reversed

        details
      end.compact.flatten
    end

    # only show result details for failed or errored results
    # show result details if a skip or passed result was issues w/ a message
    def show_result_details?(result)
      ([:fail, :error].include?(result.to_sym)) ||
      ([:skip, :ignore].include?(result.to_sym) && result.message)
    end

    # return a list of result symbols that have actually occurred
    def ocurring_result_types
      @result_types ||= [
        :pass, :fail, :ignore, :skip, :error
      ].select { |result_sym| self.count(result_sym) > 0 }
    end

    # print a result summary message for a given result type
    def result_summary_msg(result_type)
      if result_type == :pass && self.all_pass?
        self.all_pass_result_summary_msg
      else
        "#{self.count(result_type)} #{result_type.to_s}"
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

    # generate a sentence fragment describing the breakdown of test results
    # if a block is given, yield each msg in the breakdown for custom formatting
    def results_summary_sentence
      summaries = self.ocurring_result_types.collect do |result_sym|
        summary_msg = self.result_summary_msg(result_sym)
        block_given? ? yield(summary_msg, result_sym) : summary_msg
      end
      self.to_sentence(summaries)
    end

    def test_count_statement
      "#{self.count(:tests)} test#{'s' if self.count(:tests) != 1}"
    end

    def result_count_statement
      "#{self.count(:results)} result#{'s' if self.count(:results) != 1}"
    end

    # generate a comma-seperated sentence fragment given a list of things
    def to_sentence(things)
      if things.size <= 2
        things.join(things.size == 2 ? ' and ' : '')
      else
        [things[0..-2].join(", "), things.last].join(", and ")
      end
    end

  end

end
