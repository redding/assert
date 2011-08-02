require 'test_belt'

require 'assert/suite'
require 'assert/context'
require 'assert/test'
require 'fixtures/inherited_stuff'
require 'fixtures/sample_context'


class Assert::Suite

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "an basic suite"
    subject { Assert::Suite.new }

    should have_instance_method :<<, :contexts, :test_count, :assert_count

    should "be a hash" do
      assert_kind_of ::Hash, subject
    end

    should "push contexts on itself" do
      context = Assert::Context
      subject << context.class
      assert_equal true, subject.has_key?(context.class)
      assert_equal [], subject[context.class]
    end

    should "determine a klass' local public test methods" do
      assert_equal(
        ["test_subclass_stuff", "test_mixin_stuff"].sort,
        subject.send(:local_public_test_methods, SubStuff).sort
      )
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
    before { subject.contexts.each {|c| c.run} }

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

  class CountTest < WithTestsTest

    should "count its tests" do
      assert_equal subject.test_count, subject.count(:tests)
    end

    should "count its assertions" do
      assert_equal subject.assert_count, subject.count(:assertions)
    end

    should "count its passed assertions" do
      assert_equal subject.assert_count(:pass), subject.count(:passed)
      assert_equal subject.assert_count(:pass), subject.count(:pass)
    end

    should "count its failed assertions" do
      assert_equal subject.assert_count(:fail), subject.count(:failed)
      assert_equal subject.assert_count(:fail), subject.count(:fail)
    end

    should "count its skipped assertions" do
      assert_equal subject.assert_count(:skip), subject.count(:skipped)
      assert_equal subject.assert_count(:skip), subject.count(:skip)
    end

    should "count its errored assertions" do
      assert_equal subject.assert_count(:error), subject.count(:errored)
      assert_equal subject.assert_count(:error), subject.count(:error)
    end

  end


  class ContextsTest < WithTestsTest

    should "build context instances to run from its collection of tests" do
      assert_kind_of Assert::Context, subject.contexts.first
    end

    should "build the same number of context instances as its tests" do
      assert_equal subject.count(:tests), subject.contexts.size
    end

  end



  class PrepTest < Test::Unit::TestCase
    include TestBelt

    context "a suite with a context with local public test meths"
    subject do
      Assert::Suite[{
        TwoTests => []
      }]
    end

    should "create tests from any local public test methods with a prep call" do
      subject.send(:prep)
      assert_equal 2, subject.test_count(TwoTests)
    end

    should "not double count local public test methods with multiple prep calls" do
      subject.send(:prep)
      subject.send(:prep)
      assert_equal 2, subject.test_count(TwoTests)
    end

    should "create tests from any local public test methods with a test_count call" do
      assert_equal 2, subject.test_count(TwoTests)
    end

  end


end
