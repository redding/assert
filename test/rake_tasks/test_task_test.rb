require 'assert'

require 'assert/rake_tasks/test_task'

module Assert::RakeTasks

  class TestTaskTests < Assert::Context
    desc "the test task"
    setup do
      @task = Assert::RakeTasks::TestTask.new(:thing)
    end
    subject { @task }

    should have_accessors :name, :description, :test_files
    should have_instance_methods :ruby_args, :file_list

    should "default its accessors" do
      assert_equal :thing, subject.name
      assert_equal "Run tests for thing", subject.description
      assert_equal [], subject.test_files
    end

    should "build a file list string" do
      subject.test_files = ["test_one_test.rb", "test_two_test.rb"]
      assert_equal "\"test_one_test.rb\" \"test_two_test.rb\"", subject.file_list
    end

    should "know its ruby args" do
      # no -rrubygems arg added b/c we are running in bundler
      assert_equal "\"#{subject.send(:rake_loader)}\" #{subject.file_list}", subject.ruby_args
    end

  end

end
