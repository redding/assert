require 'test_belt'
require 'assert/suite'

class Assert::Suite

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "an basic suite"
    subject { Assert::Suite.new }

    should have_instance_method :run, :<<

    should "be a hash" do
      assert_kind_of ::Hash, subject
    end

    should "return an integer exit code" do
      assert_equal 0, subject.run
    end

    should "push contexts on itself" do
      context = Assert::Context.new
      subject << context.class
      assert_equal true, subject.has_key?(context.class)
      assert_equal [], subject[context.class]
    end

  end

end