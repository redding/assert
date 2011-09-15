require 'assert'

require 'assert/rake_tasks/test_task'

module Assert::RakeTasks

  class TestTaskTests < Assert::Context
    desc "the test task"
    setup do
      @task = Assert::RakeTasks::TestTask.new('thing')
      @some_thing = Assert::RakeTasks::TestTask.new('test/some/thing')
    end
    subject { @task }

    should have_accessors :path, :files
    should have_instance_methods :relative_path, :scope_description, :description
    should have_instance_methods :file_list, :ruby_args

    should "default with empty files collection" do
      assert_equal [], subject.files
    end

    should "know its relative path" do
      assert_equal "", subject.relative_path
      assert_equal "some/thing", @some_thing.relative_path
    end

    should "know its scope description" do
      assert_equal "", subject.scope_description
      assert_equal " for some/thing", @some_thing.scope_description
    end

    should "know its task description" do
      assert_equal "Run all tests", subject.description
      assert_equal "Run all tests for some/thing", @some_thing.description
    end

    should "build a file list string" do
      subject.files = ["test_one_test.rb", "test_two_test.rb"]
      assert_equal "\"test_one_test.rb\" \"test_two_test.rb\"", subject.file_list
    end

    should "know its ruby args" do
      subject.files = ["test_one_test.rb", "test_two_test.rb"]
      # no -rrubygems arg added b/c we are running in bundler
      assert_equal "\"#{subject.send(:rake_loader)}\" #{subject.file_list}", subject.ruby_args
    end

  end

end
