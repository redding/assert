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

    def tests_to_run?;      self.config.suite.tests_to_run?;      end
    def tests_to_run_count; self.config.suite.tests_to_run_count; end

    def test_count;          self.config.suite.test_count;          end
    def result_count;        self.config.suite.result_count;        end
    def pass_result_count;   self.config.suite.pass_result_count;   end
    def fail_result_count;   self.config.suite.fail_result_count;   end
    def error_result_count;  self.config.suite.error_result_count;  end
    def skip_result_count;   self.config.suite.skip_result_count;   end
    def ignore_result_count; self.config.suite.ignore_result_count; end

    def all_pass?
      self.pass_result_count == self.result_count
    end

    def formatted_run_time(run_time, format = '%.6f')
      format % run_time
    end

    def formatted_test_rate(test_rate, format = '%.6f')
      format % test_rate
    end

    def formatted_result_rate(result_rate, format = '%.6f')
      format % result_rate
    end

    def formatted_suite_run_time(format = '%.6f')
      formatted_run_time(self.config.suite.run_time, format)
    end

    def formatted_suite_test_rate(format = '%.6f')
      formatted_test_rate(self.config.suite.test_rate, format)
    end

    def formatted_suite_result_rate(format = '%.6f')
      formatted_result_rate(self.config.suite.result_rate, format)
    end

    def show_test_profile_info?
      !!self.config.profile
    end

    def show_test_verbose_info?
      !!self.config.verbose
    end

    # return a list of result type symbols that have actually occurred
    def ocurring_result_types
      @result_types ||= [:pass, :fail, :ignore, :skip, :error].select do |sym|
        self.send("#{sym}_result_count") > 0
      end
    end

    private

    def get_rate(count, time)
      time == 0 ? 0.0 : (count.to_f / time.to_f)
    end

  end

end
