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

    # the path test file "#{path}_test.rb" (if it exists) plus all deeply
    # nested test files under the path
    def test_files
      nested_files = Rake::FileList["#{@path}/**/*#{self.class.test_file_suffix}"]
      path_file_name = @path+self.class.test_file_suffix
      (File.exists?(path_file_name) ? Rake::FileList[path_file_name] : []) + nested_files
    end

    # return a test task covering the scopes test files (return nothing if no test files)
    def to_test_task
      if !self.test_files.empty?
        TestTask.new(@path) do |tt|
          tt.files = self.test_files
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
















    # def relative_path
    #   self.class.relative_path(@test_root)
    # end

    # def scope
    #   self.class.scope(self.relative_path)
    # end

    # def description
    #   self.class.description(self.scope)
    # end

    # # get any root test file plus any nested test files for the test root
    # def test_files_paths
    #   root_test_file_path = FileList[self.class.test_file_path(@test_root.to_s)]
    #   nested_test_files_paths = FileList["#{@test_root.to_s}/**/*#{self.class.test_file_suffix}"]
    #   root_test_file_path + nested_test_files_paths
    # end

    # # scopes for any test files or folders immediately under the test root
    # def child_test_scopes
    #   Dir.glob(File.join(@test_root.to_s, "*")).collect do |path|
    #     File.join(File.dirname(path), File.basename(path, self.class.test_file_suffix))
    #   end.uniq
    # end

    # # paths to any test files immediately under the test root
    # def child_test_file_paths
    #   self.class.child_test_file_paths(@test_root.to_s)
    # end

    # # build a test task for all immediate test files without sub-folder tests
    # def test_tasks
    #   self.child_test_scopes.collect do |scope|
    #     scope_test_file = self.class.test_file_path(scope)
    #     nested_scope_test_files = Dir.glob(File.join(scope, "*#{self.class.test_file_suffix}"))

    #     handler = Tests.new(scope)

    #     # if there is a test file and no nested test files for this scope
    #     if File.exists?(scope_test_file) && nested_scope_test_files.empty?
    #       # build a test task for running that test file
    #       desc = self.class.description(self.class.scope(self.class.relative_path(scope)))
    #       TestTask.new(File.basename(scope).to_sym) do |t|
    #         t.description = desc
    #         t.test_files = FileList[scope_test_file]
    #       end
    #     end
    #   end

    # end

  end
end
