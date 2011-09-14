require 'assert/rake_tasks/irb'

module Assert::RakeTasks
  class Handler

    def self.irb(path)
      Irb.new(path)
    end

  end
end
