require 'test_belt'
require 'assert/suite'

class Assert::Suite

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "a suitet"
    subject { Assert::Suite.new }

    should "be a sorted set" do
      assert_kind_of SortedSet, subject
    end

  end

end