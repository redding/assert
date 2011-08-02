require 'test_belt'

require 'assert/runner'
require 'assert/suite'

class Assert::Runner

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "an basic suite"
    subject { Assert::Runner.new(Assert::Suite.new) }

    should have_instance_method :run, :time, :count

    should "return an integer exit code" do
      assert_equal 0, subject.run
    end

  end

end
