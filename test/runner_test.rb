require 'assert'

require 'assert/suite'
require 'assert/view/base'
require 'assert/runner'

class Assert::Runner

  class BasicTest < Assert::Context
    desc "a basic runner"
    setup do
      @suite  = Assert::Suite.new
      @view   = Assert::View::Base.new(@suite, StringIO.new("", "w+"))
      @runner = Assert::Runner.new(@suite, @view)
    end
    subject { @runner }

    INSTANCE_METHODS = [
      :run, :count
    ]
    INSTANCE_METHODS.each do |method|
      should "respond to the instance method ##{method}" do
        assert_respond_to subject, method
      end
    end

    should "return an integer exit code" do
      assert_equal 0, subject.run
    end

  end

end
