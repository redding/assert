require 'assert'

require 'assert/rake_tasks/handler'

module Assert::RakeTasks

  class HandlerTests < Assert::Context
    desc "the basic rake tasks handler"
    setup do
      @handler = Assert::RakeTasks::Handler
    end
    subject { @handler }

    should have_instance_methods :irb

    should "build an IRB rake task handler" do
      assert_kind_of Irb, subject.irb(:test)
    end

  end

end
