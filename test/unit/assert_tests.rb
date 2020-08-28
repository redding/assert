require "assert"

require "assert/config"
require "assert/stub"
require "much-stub"

module Assert
  class UnitTests < Assert::Context
    desc "Assert"
    subject { Assert }

    should have_imeths :config, :configure, :view, :suite, :runner
    should have_imeths :stubs, :stub, :unstub, :unstub!, :stub_send

    should "know its config instance" do
      assert_that(subject.config).is_kind_of(Assert::Config)
    end

    should "map its view, suite and runner to its config" do
      assert_that(subject.view).is_the_same_as(subject.config.view)
      assert_that(subject.suite).is_the_same_as(subject.config.suite)
      assert_that(subject.runner).is_the_same_as(subject.config.runner)
    end

    # Note: don't really need to explicitly test the configure method as
    # nothing runs if it isn't working
  end

  class StubTests < UnitTests
    # setup do
    #   orig_value1 = Factory.string
    #   stub_value1 = Factory.string

    #   @myclass =
    #   Class.new do
    #     def initialize(value); @value = value; end
    #     def mymeth; @value; end
    #   end
    #   object1 = @myclass.new(orig_value1)
    # end

    let(:class1) {
      Class.new do
        def initialize(value); @value = value; end
        def mymeth; @value; end
      end
    }
    let(:object1) { class1.new(orig_value1) }
    let(:orig_value1) { Factory.string }
    let(:stub_value1) { Factory.string }

    should "build a stub" do
      stub1 = Assert.stub(object1, :mymeth)
      assert_that(stub1).is_kind_of(MuchStub::Stub)
    end

    should "lookup stubs that have been called before" do
      stub1 = Assert.stub(object1, :mymeth)
      stub2 = Assert.stub(object1, :mymeth)
      assert_that(stub2).is_the_same_as(stub1)
    end

    should "set the stub's do block if given a block" do
      Assert.stub(object1, :mymeth)
      assert_that(-> { object1.mymeth }).raises(MuchStub::NotStubbedError)
      Assert.stub(object1, :mymeth){ stub_value1 }
      assert_that(object1.mymeth).equals(stub_value1)
    end

    should "teardown stubs" do
      assert_that(object1.mymeth).equals(orig_value1)
      Assert.unstub(object1, :mymeth)
      assert_that(object1.mymeth).equals(orig_value1)

      assert_that(object1.mymeth).equals(orig_value1)
      Assert.stub(object1, :mymeth){ stub_value1 }
      assert_that(object1.mymeth).equals(stub_value1)
      Assert.unstub(object1, :mymeth)
      assert_that(object1.mymeth).equals(orig_value1)
    end

    should "know and teardown all stubs" do
      assert_that(object1.mymeth).equals(orig_value1)

      Assert.stub(object1, :mymeth){ stub_value1 }
      assert_that(object1.mymeth).equals(stub_value1)
      assert_that(Assert.stubs.size).equals(1)

      Assert.unstub!
      assert_that(object1.mymeth).equals(orig_value1)
      assert_that(Assert.stubs).is_empty
    end

    should "auto-unstub any stubs on teardown" do
      context_class = ::Factory.modes_off_context_class do
        setup do
          Assert.stub("1", :to_s){ "one" }
        end
      end

      context_class.run_setups("scope")
      assert_that(Assert.stubs.size).equals(1)

      context_class.run_teardowns("scope")
      assert_that(Assert.stubs).is_empty
    end

    should "be able to call a stub's original method" do
      err =
        assert_that(-> { Assert.stub_send(object1, :mymeth) }).
          raises(MuchStub::NotStubbedError)
      assert_that(err.message).includes("not stubbed.")
      assert_that(err.backtrace.first).includes("test/unit/assert_tests.rb")

      Assert.stub(object1, :mymeth){ stub_value1 }

      assert_that(object1.mymeth).equals(stub_value1)
      assert_that(Assert.stub_send(object1, :mymeth)).equals(orig_value1)
    end

    should "be able to add a stub tap" do
      my_meth_called_with = nil
      Assert.stub_tap(object1, :mymeth){ |value, *args, &block|
        my_meth_called_with = args
      }

      assert_that(object1.mymeth).equals(orig_value1)
      assert_that(my_meth_called_with).equals([])
    end

    should "be able to add a stub tap with an on_call block" do
      my_meth_called_with = nil
      Assert.stub_tap_on_call(object1, :mymeth){ |value, call|
        my_meth_called_with = call
      }

      assert_that(object1.mymeth).equals(orig_value1)
      assert_that(my_meth_called_with.args).equals([])
    end

    should "be able to add a stubbed spy" do
      myclass = Class.new do
        def one; self; end
        def two(val); self; end
        def three; self; end
        def ready?; false; end
      end
      myobj = myclass.new

      spy =
        Assert.stub_spy(
          myobj,
          :one,
          :two,
          :three,
          ready?: true)

      assert_that(myobj.one).equals(spy)
      assert_that(myobj.two("a")).equals(spy)
      assert_that(myobj.three).equals(spy)

      assert_that(myobj.one.two("b").three.ready?).is_true

      assert_that(spy).is_kind_of(MuchStub::CallSpy)
      assert_that(spy.one_call_count).equals(2)
      assert_that(spy.two_call_count).equals(2)
      assert_that(spy.three_call_count).equals(2)
      assert_that(spy.ready_predicate_call_count).equals(1)
      assert_that(spy.two_last_called_with.args).equals(["b"])
      assert_that(spy.ready_predicate_called?).is_true
    end
  end
end
