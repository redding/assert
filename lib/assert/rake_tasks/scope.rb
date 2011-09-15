require 'rake/tasklib'
require 'assert/rake_tasks/test_task'

module Assert::RakeTasks
  class Scope

    def self.test_file_suffix
      "_test.rb"
    end

    def initialize(path)
      @path = path
    end

    def namespace
      File.basename(@path).to_sym
    end

    # nested test files under the path
    def nested_files
      nested_files = Rake::FileList["#{@path}/**/*#{self.class.test_file_suffix}"]
    end

    # a list with the path test file "#{path}_test.rb" (if it exists)
    def path_file_list
      path_file_name = @path+self.class.test_file_suffix
      (File.exists?(path_file_name) ? Rake::FileList[path_file_name] : [])
    end

    # return a test task covering the scopes nested files plus path file
    # but only if there are nested files
    def to_test_task
      if !self.nested_files.empty?
        TestTask.new(@path) do |tt|
          tt.files = self.path_file_list + self.nested_files
        end
      end
    end

    # a collection of test tasks for every standalone child test file
    def test_tasks
      # get immediate child test files
      Dir.glob("#{@path}/*#{self.class.test_file_suffix}").collect do |f|
        # get just the path name for each file
        File.join(File.dirname(f), File.basename(f, self.class.test_file_suffix))
      end.reject do |p|
        # reject any that have deeply nested test files
        !Dir.glob("#{p}/**/*#{self.class.test_file_suffix}").empty?
      end.collect do |p|
        # build a test task for the standalone test file of the path
        TestTask.new(p) do |tt|
          tt.files = Rake::FileList[p+self.class.test_file_suffix]
        end
      end
    end

    # a collection of scopes for every child test dir or test dir/file combo
    def scopes
      # get immediate child paths
      Dir.glob("#{@path}/*").collect do |p|
        # get just the path name for each dir/file and uniq it
        File.join(File.dirname(p), File.basename(p, self.class.test_file_suffix))
      end.uniq.select do |p|
        # select any that have deeply nested test files
        !Dir.glob("#{p}/**/*#{self.class.test_file_suffix}").empty?
      end.collect do |p|
        # build a scope for each path
        self.class.new(p)
      end
    end

  end
end
