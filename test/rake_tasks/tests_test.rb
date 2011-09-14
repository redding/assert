require 'assert'

require 'assert/rake_tasks/tests'

module Assert::RakeTasks

  class TestsTests < Assert::Context
    desc "the tests task handler"
    setup do
      @root_path = :test
      @handler = Assert::RakeTasks::Tests.new(@root_path)
    end
    subject { @handler }

    should have_instance_methods :has_tests?, :description, :test_files
    should have_instance_methods :test_tasks, :test_paths

    # should "know its rake task name" do
    #   assert_equal :irb, subject.class.task_name
    # end

    # should "know the irb helper file name" do
    #   assert_equal "irb.rb", subject.class.file_name
    # end

    # should "know the irb helper file path" do
    #   assert_equal File.join(@root_path.to_s, subject.class.file_name), subject.file_path
    # end

    # should "know if the irb helper exists" do
    #   # this is true b/c assert has a test/helper.rb file defined
    #   assert_equal true, subject.helper_exists?
    # end

    # should "know the description of the irb task" do
    #   assert_equal "Open irb preloaded with #{subject.file_path}", subject.description
    # end

    # should "know the shell command to run the irb task" do
    #   assert_equal "irb -rubygems -r ./#{subject.file_path}", subject.cmd
    # end

  end

end
