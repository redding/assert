require 'assert/runner'

module Assert

  # This is the default runner used by assert.  It runs the tests one at a time
  # in random order

  class DefaultRunner < Assert::Runner

    def on_start
      if self.tests?
        self.view.puts "Running tests in random order, seeded with \"#{self.runner_seed}\""
      end
    end

    def run!(&block)
      srand self.runner_seed
      self.suite.tests.sort.sort_by{ rand self.suite.tests.size }.each(&block)
    end

  end

end
