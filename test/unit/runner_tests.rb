require 'assert'
require 'assert/suite'
require 'assert/view/base'
require 'assert/runner'

class Assert::Runner

  class BasicTests < Assert::Context
    desc "a basic runner"
    setup do
      @suite  = Assert::Suite.new
      @view   = Assert::View::Base.new(StringIO.new("", "w+"), @suite)
      @runner = Assert::Runner.new
    end
    subject { @runner }

    should have_instance_methods :run

    should "return an integer exit code" do
      assert_equal 0, subject.run(@suite, @view)
    end

  end

end
