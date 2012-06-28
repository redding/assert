require 'rake/tasklib'
require 'assert/rake_tasks/test_task'

module Assert::RakeTasks
  class Scope

    def self.test_file_suffixes
      ['_test.rb', '_tests.rb']
    end

    attr_reader :path, :nested_files, :path_file_list, :test_tasks, :scopes

    def initialize(path)
      @path = path

      @nested_files = get_nested_files
      @path_file_list = build_path_file_list
      @test_tasks = build_test_tasks
      @scopes = build_scopes
    end

    def namespace
      File.basename(@path).to_sym
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

    protected

    # nested test files under the path

    def get_nested_files
      self.class.test_file_suffixes.map do |suffix|
        Rake::FileList["#{@path}/**/*#{suffix}"]
      end.flatten
    end

    # a list with the path test file "#{path}_test.rb" (if it exists)

    def build_path_file_list
      self.class.test_file_suffixes.map do |suffix|
        path_file_name = "#{@path}#{suffix}"
        File.exists?(path_file_name) ? Rake::FileList[path_file_name] : []
      end.flatten
    end

    # a collection of test tasks for every standalone child test file

    def build_test_tasks
      self.class.test_file_suffixes.map do |suffix|
        # get immediate child test files
        Dir.glob("#{@path}/*#{suffix}").collect do |f|
          # get just the path name for each file
          File.join(File.dirname(f), File.basename(f, suffix))
        end
      end.flatten.reject do |p|
        # reject any that have deeply nested test files
        self.class.test_file_suffixes.inject(false) do |result, suffix|
          result || !Dir.glob("#{p}/**/*#{suffix}").empty?
        end
      end.collect do |p|
        # build a test task for the standalone test file of the path
        TestTask.new(p) do |tt|
          tt.files = self.class.test_file_suffixes.map do |suffix|
            (File.exists?("#{p}#{suffix}") ? Rake::FileList["#{p}#{suffix}"] : [])
          end.flatten
        end
      end
    end

    # a collection of scopes for every child test dir or test dir/file combo

    def build_scopes
      self.class.test_file_suffixes.map do |suffix|
        # get immediate child paths
        Dir.glob("#{@path}/*").collect do |p|
          # get just the path name for each dir/file and uniq it
          File.join(File.dirname(p), File.basename(p, suffix))
        end
      end.flatten.uniq.select do |p|
        # select any that have deeply nested test files
        self.class.test_file_suffixes.inject(false) do |result, suffix|
          result || !Dir.glob("#{p}/**/*#{suffix}").empty?
        end
      end.collect do |p|
        # build a scope for each path
        self.class.new(p)
      end
    end

  end
end
