require 'rake'
require 'rake/tasklib'

module Assert; end
module Assert::RakeTasks

  FILE_SUFFIX = "_test.rb"

  # Setup the rake tasks for testing
  # * add 'include Assert::RakeTasks' to your Rakefile
  def self.included(receiver)
    # get rid of rake warnings
    if defined?(::Rake::DSL)
      receiver.send :include, ::Rake::DSL
    end

    # auto-build rake tasks for the ./test files (if defined in ./test)
    self.for(:test) if File.exists?(File.expand_path('./test', Dir.pwd))
  end

  def self.for(test_namespace = :test)
    self.irb_task(test_namespace.to_s)
    self.to_tasks(test_namespace.to_s)
  end




  class TestTask < Rake::TaskLib
    attr_accessor :name, :description, :test_files

    # Create a testing task.
    def initialize(name=:test)
      @name = name
      @description = "Run tests" + (@name==:test ? "" : " for #{@name}")
      @test_files = []
      yield self if block_given?
    end

    # Define the rake task to run this test suite
    def to_task
      desc @description
      task @name do
        RakeFileUtils.verbose(true) { ruby "\"#{rake_loader}\" " + file_list }
      end
    end

    def file_list # :nodoc:
      @test_files.collect{|f| "\"#{f}\""}.join(' ')
    end

    protected

    def rake_loader # :nodoc:
      find_file('rake/rake_test_loader') or
        fail "unable to find rake test loader"
    end

    def find_file(fn) # :nodoc:
      $LOAD_PATH.each do |path|
        file_path = File.join(path, "#{fn}.rb")
        return file_path if File.exist? file_path
      end
      nil
    end
  end

  class << self
    def irb_task(path)
      irb_file = File.join(path, "irb.rb")
      if File.exist?(irb_file)
        desc "Open irb preloaded with #{irb_file}"
        task :irb do
          sh "irb -rubygems -r ./#{irb_file}"
        end
      end
    end

    def to_tasks(path)
      suite_name = File.basename(path)

      # define a rake test task for all test files that have addional sub-folder tests
      if !Dir.glob(File.join(path, "**/*#{FILE_SUFFIX}")).empty?
        TestTask.new(suite_name.to_sym) do |t|
          file_location = suite_name == path ? '' : " for #{File.join(path.split(File::SEPARATOR)[1..-1])}"
          t.description = "Run all tests#{file_location}"
          t.test_files = (File.exists?(p = (path+FILE_SUFFIX)) ? FileList[p] : []) + FileList["#{path}/**/*#{FILE_SUFFIX}"]
        end.to_task
      end

      namespace suite_name.to_s do
        Dir.glob(File.join(path, "*#{FILE_SUFFIX}")).each do |test_file|
          test_name = File.basename(test_file, FILE_SUFFIX)

          # define rake test task for all test files without sub-folder tests
          if Dir.glob(File.join(path, test_name, "*#{FILE_SUFFIX}")).empty?
            TestTask.new(test_name.to_sym) do |t|
              t.description = "Run tests for #{[path.split(File::SEPARATOR), test_name].flatten[1..-1].join(':')}"
              t.test_files = FileList[test_file]
            end.to_task
          end
        end

        # recursively define rake test tasks for each file
        # in each top-level directory
        Dir.glob(File.join(path, "*")).each do |test_dir|
          self.to_tasks(test_dir)
        end
      end
    end
  end

end
