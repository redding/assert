require 'test_belt'
require 'assert/suite'
require 'assert/context'
require 'assert/test'

class Assert::Suite

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "an basic suite"
    subject { Assert::Suite.new }

    should have_instance_method :<<, :run, :count

    should "be a hash" do
      assert_kind_of ::Hash, subject
    end

    should "push contexts on itself" do
      context = Assert::Context
      subject << context.class
      assert_equal true, subject.has_key?(context.class)
      assert_equal [], subject[context.class]
    end

  end

  class WithTestsTest < Test::Unit::TestCase
    include TestBelt

    context "an suite with tests"
    subject do
      Assert::Suite[{
        'Assert::Context' => [
          Assert::Test.new("should do nothing", ::Proc.new do
            # no assertions
          end),
          Assert::Test.new("should pass", ::Proc.new do
            # passing assertion
          end),
          Assert::Test.new("should fail", ::Proc.new do
            # failing assertion
          end),
          Assert::Test.new("should skip", ::Proc.new do
            #skipped assertion
          end),
          Assert::Test.new("should error", ::Proc.new do
          end)
        ]
      }]
    end

    should "know how many tests it has" do
      assert_equal 5, subject.send(:test_count)
    end

  end

end