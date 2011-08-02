require 'test_belt'
require 'assert/suite'
require 'assert/context'
require 'assert/test'

class Assert::Suite

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "an basic suite"
    subject { Assert::Suite.new }

    should have_instance_method :<<, :run, :test_count, :assert_count

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
        Assert::Context => [
          Assert::Test.new("should do nothing", ::Proc.new do
            # no assertions
          end),
          Assert::Test.new("should pass", ::Proc.new do
            assert(1==1)
            refute(1==0)
          end),
          Assert::Test.new("should fail", ::Proc.new do
            assert(1==0)
            refute(1==1)
          end),
          Assert::Test.new("should skip", ::Proc.new do
            skip
            assert(1==1)
          end),
          Assert::Test.new("should error", ::Proc.new do
            raise Exception
            assert(1==1)
          end)
        ]
      }]
    end
    before { subject.run }

    should "know how many tests it has" do
      assert_equal 5, subject.test_count
    end

    should "know how many assertions it has" do
      assert_equal 6, subject.assert_count
    end

    should "know how many pass assertions it has" do
      assert_equal 2, subject.assert_count(:pass)
    end

    should "know how many fail assertions it has" do
      assert_equal 2, subject.assert_count(:fail)
    end

    should "know how many skip assertions it has" do
      assert_equal 1, subject.assert_count(:skip)
    end

    should "know how many error assertions it has" do
      assert_equal 1, subject.assert_count(:error)
    end

  end

end
