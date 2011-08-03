require 'test_belt'
require 'stringio'

require 'assert/runner'
require 'assert/suite'

class Assert::Runner

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "an basic suite"
    subject { Assert::Runner.new(Assert::Suite.new, StringIO.new("", "w+")) }

    should have_instance_method :run, :count

    should "return an integer exit code" do
      assert_equal 0, subject.run
    end

  end

end
