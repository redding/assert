module Assert::RakeTasks
  class Irb

    def self.file_name
      "irb.rb"
    end

    def self.task_name
      :irb
    end

    def initialize(test_root)
      @test_root = test_root
    end

    def file_path
      File.join(@test_root.to_s, self.class.file_name)
    end

    def helper_exists?
      File.exists?(self.file_path)
    end

    def description
      "Open irb preloaded with #{self.file_path}"
    end

    def cmd
      "irb -rubygems -r #{self.file_path}"
    end

  end
end
