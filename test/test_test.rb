require 'test_belt'
require 'assert/test'

require 'assert/context'
require 'assert/suite'

class Assert::Test

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "a Test"
    subject { Assert::Test.new("should do stuff", ::Proc.new {}) }

    should have_readers :name, :code
    should have_accessor :result

    should "know its name" do
      assert_equal "should do stuff", subject.name
    end

  end

  class ResultTest < Test::Unit::TestCase
    include TestBelt

    context "that runs"
    before do
      Assert::Suite[{Assert::Context => [subject]}].run
    end
  end

  class PassTest < ResultTest
    context "and passes"
    subject do
      Assert::Test.new("should assert stuff", ::Proc.new do
        assert(1 == 1)
        #assert { 1 == 0 }
        #assert {  }
        #assert { raise ArgumentError }
      end)
    end

    should "have a passing result" do
      assert_kind_of Assert::Result::Pass, subject.result
    end

  end

end
