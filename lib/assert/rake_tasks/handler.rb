require 'assert/rake_tasks/test_task'
require 'assert/rake_tasks/irb'
require 'assert/rake_tasks/tests'

module Assert::RakeTasks
  class Handler

    def self.irb(path)
      Irb.new(path)
    end

    def self.tests(path)
      Tests.new(path)
    end

  end
end
