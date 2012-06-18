require 'assert'

require 'assert/rake_tasks/scope'

module Assert::RakeTasks

  class ScopeTests < Assert::Context
    desc "the scope rake tasks handler"
    setup do
      @scope_root = 'test/fixtures'
      @handler = Assert::RakeTasks::Scope.new(File.join(@scope_root, 'test_root'))
    end
    subject { @handler }

    should have_class_methods :test_file_suffixes
    should have_instance_methods :namespace, :nested_files, :path_file_list, :to_test_task
    should have_instance_methods :test_tasks, :scopes

    should "know its the test file suffix" do
      assert_equal ['_test.rb', '_tests.rb'], subject.class.test_file_suffixes
    end

    should "know its namespace" do
      assert_equal :test_root, subject.namespace
      assert_equal :shallow, Assert::RakeTasks::Scope.new(File.join(@scope_root, 'test_root/shallow')).namespace
    end

    should "know its nested files" do
      assert_equal 6, subject.nested_files.size
      assert_empty Assert::RakeTasks::Scope.new('does/not/exist').nested_files

      h = Assert::RakeTasks::Scope.new("#{@scope_root}/test_root/shallow")
      assert_equal 2, h.nested_files.size
    end

    should "know its path file" do
      assert_empty subject.path_file_list

      h = Assert::RakeTasks::Scope.new("#{@scope_root}/test_root/shallow")
      assert_equal 1, h.path_file_list.size
    end

    should "convert to a test task" do
      assert_not Assert::RakeTasks::Scope.new('does/not/exist').to_test_task

      tt = subject.to_test_task
      assert_kind_of TestTask, tt
      assert_equal subject.nested_files.size+subject.path_file_list.size, tt.files.size
    end

    should "have a test task for each standalone test file" do
      assert_equal 2, subject.test_tasks.size
      assert_kind_of TestTask, subject.test_tasks.first
    end

    should "have a scope for each immediate test dir or test dir/file in the scope" do
      assert_equal 2, subject.scopes.size
      assert_kind_of Scope, subject.scopes.first
    end

  end

end
