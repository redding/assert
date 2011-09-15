require 'assert'

require 'assert/rake_tasks/scope'

module Assert::RakeTasks

  class ScopeTests < Assert::Context
    desc "the scope rake tasks handler"
    setup do
      @scope_root = 'test/fixtures'
      @test_scope = 'test/rake_tasks'
      @handler = Assert::RakeTasks::Scope.new(File.join(@scope_root, 'test_root'))
    end
    subject { @handler }

    should have_class_methods :test_file_suffix
    should have_instance_methods :namespace, :test_files, :to_test_task
    should have_instance_methods :test_tasks, :scopes

    should "know its the test file suffix" do
      assert_equal "_test.rb", subject.class.test_file_suffix
    end

    should "know its namespace" do
      assert_equal :test_root, subject.namespace
      assert_equal :shallow, Assert::RakeTasks::Scope.new(File.join(@scope_root, 'test_root/shallow')).namespace
    end

    should "know its test files" do
      assert_equal 6, subject.test_files.size
      assert_empty Assert::RakeTasks::Scope.new('does/not/exist').test_files
    end

    should "convert to a test task" do
      assert_not Assert::RakeTasks::Scope.new('does/not/exist').to_test_task

      tt = subject.to_test_task
      assert_kind_of TestTask, tt
      assert_equal subject.test_files.size, tt.files.size
    end

    should "have a test task for each standalone test file" do
      assert_equal 2, subject.test_tasks.size
      assert_kind_of TestTask, subject.test_tasks.first
    end

    should "have a scope for each immediate test dir or test dir/file in the scope" do
      assert_equal 2, subject.scopes.size
      assert_kind_of Scope, subject.scopes.first
    end









    # should "know its relative path" do
    #   assert_equal "", subject.relative_path
    #   assert_equal "", subject.class.relative_path('test')
    #   assert_equal "some/thing", @thing_handler.relative_path
    #   assert_equal "some/thing", @thing_handler.class.relative_path('test/some/thing')
    # end

    # should "know its scope" do
    #   assert_equal "", subject.scope
    #   assert_equal "", subject.class.scope
    #   assert_equal " for some/thing", @thing_handler.scope
    #   assert_equal " for some/thing", @thing_handler.class.scope("some/thing")
    # end

    # should "know its task description" do
    #   unscoped = "Run all tests"
    #   assert_equal unscoped, subject.description
    #   assert_equal unscoped, subject.class.description
    #   scoped = "Run all tests for some/thing"
    #   assert_equal scoped, @thing_handler.description
    #   assert_equal scoped, @thing_handler.class.description(" for some/thing")
    # end

    # should "know its test files" do
    #   context_test_files = ["test/context_test.rb", "test/context/class_methods_test.rb"]
    #   context_path = 'test/context'
    #   assert_equal context_test_files, Assert::RakeTasks::Tests.new(context_path).test_files
    # end

    # should "know its child test scopes" do
    #   exp_child_test_scopes = @test_scope_child_file_paths.collect do |s|
    #     s.gsub subject.class.test_file_suffix, ""
    #   end
    #   child_test_scopes = Assert::RakeTasks::Tests.new(@test_scope).child_test_scopes
    #   assert_equal exp_child_test_scopes, child_test_scopes
    # end

    # should "know its child test file paths" do
    #   exp_child_file_paths = @test_scope_child_file_paths
    #   child_file_paths = Assert::RakeTasks::Tests.new(@test_scope).child_test_file_paths
    #   assert_equal exp_child_file_paths, child_file_paths
    # end

    # should "know its test tasks" do
    #   test_tasks = Assert::RakeTasks::Tests.new(@test_scope).test_tasks
    #   puts test_tasks.collect{|tt| tt.inspect}.join("\n")
    #   assert_equal 3, test_tasks.size
    #   assert_kind_of TestTask, test_tasks.first
    # end

  end

end
