module Assert

  module ConfigHelpers

    def runner; self.config.runner; end
    def suite;  self.config.suite;  end
    def view;   self.config.view;   end

    def runner_seed
      self.config.runner_seed
    end

    def single_test?
      self.config.single_test?
    end

    def single_test_file_line
      self.config.single_test_file_line
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

    def formatted_run_time(format = '%.6f')
      format % self.config.suite.run_time
    end

    def formatted_test_rate(format = '%.6f')
      format % self.config.suite.test_rate
    end

    def formatted_result_rate(format = '%.6f')
      format % self.config.suite.result_rate
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
