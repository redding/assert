module Assert

  module ConfigHelpers

    def runner_seed
      self.config.runner_seed
    end

    def count(type)
      self.config.suite.count(type)
    end

    def tests?
      self.count(:tests) > 0
    end

    def all_pass?
      self.count(:pass) == self.count(:results)
    end

    # get the formatted suite run time
    def run_time(format = '%.6f')
      format % self.config.suite.run_time
    end

    # get the formatted suite test rate
    def test_rate(format = '%.6f')
      format % self.config.suite.test_rate
    end

    # get the formatted suite result rate
    def result_rate(format = '%.6f')
      format % self.config.suite.result_rate
    end

    # get a uniq list of contexts for the test suite
    def suite_contexts
      @suite_contexts ||= self.config.suite.tests.inject([]) do |contexts, test|
        contexts << test.context_info.klass
      end.uniq
    end

    def ordered_suite_contexts
      self.suite_contexts.sort{ |a,b| a.to_s <=> b.to_s }
    end

    # get a uniq list of files containing contexts for the test suite
    def suite_files
      @suite_files ||= self.config.suite.tests.inject([]) do |files, test|
        files << test.context_info.file
      end.uniq
    end

    def ordered_suite_files
      self.suite_files.sort{ |a,b| a.to_s <=> b.to_s }
    end

    def show_test_profile_info?
      !!self.config.profile
    end

    def show_test_verbose_info?
      !!self.config.verbose
    end

    # return a list of result symbols that have actually occurred
    def ocurring_result_types
      @result_types ||= [:pass, :fail, :ignore, :skip, :error].select do |sym|
        self.count(sym) > 0
      end
    end

  end

end
