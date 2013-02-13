require 'rake'

module Assert; end
module Assert::RakeTasks; end

require 'assert/rake_tasks/irb'
require 'assert/rake_tasks/scope'
require 'assert/rake_tasks/test_task'

module Assert::RakeTasks

  # Setup the rake tasks for testing
  # * add 'include Assert::RakeTasks' to your Rakefile
  def self.included(receiver)
    # auto-install rake tasks
    self.install
  end

  def self.install
    warn "[DEPRECATED] `Assert::RakeTasts` has been deprecated.  Support for running tests with Rake will be removed in v2.0.  Use the assert CLI instead."

    assert_test_root = ENV['ASSERT_TEST_ROOT'] || './test'

    if File.exists?(assert_test_root)
      self.irb_task(Assert::RakeTasks::Irb.new(assert_test_root))
      self.to_tasks(Assert::RakeTasks::Scope.new(assert_test_root))
    end
  end

  def self.for(test_root_name)
    warn "[DEPRECATED] `Assert::RakeTasts.for` has been deprecated.  Use `Assert::RakeTasks.install` instead."
  end

  class << self
    include Rake::DSL if defined? Rake::DSL

    def irb_task(irb)
      if irb.helper_exists?
        desc irb.description
        task irb.class.task_name do
          sh irb.cmd
        end
      end
    end

    def to_tasks(scope)
      # if there is a test task for the scope
      if (scope_tt = scope.to_test_task)
        # create a rake task to run it
        desc scope_tt.description
        task scope_tt.name do
          RakeFileUtils.verbose(scope_tt.show_loaded_files?) { ruby scope_tt.ruby_args }
        end
      end

      # create a namespace for the scope
      namespace scope.namespace do
        # for each test task in the scope, create a rake task to run it
        scope.test_tasks.each do |test_file_tt|
          desc test_file_tt.description
          task test_file_tt.name do
            RakeFileUtils.verbose(test_file_tt.show_loaded_files?) { ruby test_file_tt.ruby_args }
          end
        end

        # recusively generate rake tasks for each sub-scope in the scope
        scope.scopes.each do |sub_scope|
          self.to_tasks(sub_scope)
        end
      end

    end
  end

end
