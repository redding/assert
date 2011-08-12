root_path = File.expand_path("../..", __FILE__)
if !$LOAD_PATH.include?(root_path)
  $LOAD_PATH.unshift(root_path)
end
require 'test/helper'

require 'assert/runner'
require 'assert/suite'

class Assert::Runner

  class BasicTest < Assert::Context
    desc "a basic runner"
    setup do
      @runner = Assert::Runner.new(Assert::Suite.new, StringIO.new("", "w+"))
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
