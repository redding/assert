require 'test_belt'
require 'assert/suite'

class Assert::Suite

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "an empty suite"
    subject { Assert::Suite.new }

    should have_instance_method :run

    should "be a sorted set" do
      assert_kind_of SortedSet, subject
    end

    should "return an integer exit code" do
      assert_equal 0, subject.run
    end

  end

end