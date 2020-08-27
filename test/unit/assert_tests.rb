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
      assert_kind_of Assert::Config, subject.config
    end

    should "map its view, suite and runner to its config" do
      assert_same subject.config.view,   subject.view
      assert_same subject.config.suite,  subject.suite
      assert_same subject.config.runner, subject.runner
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
      assert_kind_of MuchStub::Stub, stub1
    end

    should "lookup stubs that have been called before" do
      stub1 = Assert.stub(object1, :mymeth)
      stub2 = Assert.stub(object1, :mymeth)
      assert_same stub1, stub2
    end

    should "set the stub's do block if given a block" do
      Assert.stub(object1, :mymeth)
      assert_raises(MuchStub::NotStubbedError){ object1.mymeth }
      Assert.stub(object1, :mymeth){ stub_value1 }
      assert_equal stub_value1, object1.mymeth
    end

    should "teardown stubs" do
      assert_equal orig_value1, object1.mymeth
      Assert.unstub(object1, :mymeth)
      assert_equal orig_value1, object1.mymeth

      assert_equal orig_value1, object1.mymeth
      Assert.stub(object1, :mymeth){ stub_value1 }
      assert_equal stub_value1, object1.mymeth
      Assert.unstub(object1, :mymeth)
      assert_equal orig_value1, object1.mymeth
    end

    should "know and teardown all stubs" do
      assert_equal orig_value1, object1.mymeth

      Assert.stub(object1, :mymeth){ stub_value1 }
      assert_equal stub_value1, object1.mymeth
      assert_equal 1, Assert.stubs.size

      Assert.unstub!
      assert_equal orig_value1, object1.mymeth
      assert_empty Assert.stubs
    end

    should "auto-unstub any stubs on teardown" do
      context_class = ::Factory.modes_off_context_class do
        setup do
          Assert.stub("1", :to_s){ "one" }
        end
      end

      context_class.run_setups("scope")
      assert_equal 1, Assert.stubs.size

      context_class.run_teardowns("scope")
      assert_empty Assert.stubs
    end

    should "be able to call a stub's original method" do
      err = assert_raises(MuchStub::NotStubbedError){ Assert.stub_send(object1, :mymeth) }
      assert_includes "not stubbed.",              err.message
      assert_includes "test/unit/assert_tests.rb", err.backtrace.first

      Assert.stub(object1, :mymeth){ stub_value1 }

      assert_equal stub_value1, object1.mymeth
      assert_equal orig_value1, Assert.stub_send(object1, :mymeth)
    end

    should "be able to add a stub tap" do
      my_meth_called_with = nil
      Assert.stub_tap(object1, :mymeth){ |value, *args, &block|
        my_meth_called_with = args
      }

      assert_equal orig_value1, object1.mymeth
      assert_equal [], my_meth_called_with
    end

    should "be able to add a stub tap with an on_call block" do
      my_meth_called_with = nil
      Assert.stub_tap_on_call(object1, :mymeth){ |value, call|
        my_meth_called_with = call
      }

      assert_equal orig_value1, object1.mymeth
      assert_equal [], my_meth_called_with.args
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

      assert_equal spy, myobj.one
      assert_equal spy, myobj.two("a")
      assert_equal spy, myobj.three

      assert_true myobj.one.two("b").three.ready?

      assert_kind_of MuchStub::CallSpy, spy
      assert_equal 2, spy.one_call_count
      assert_equal 2, spy.two_call_count
      assert_equal 2, spy.three_call_count
      assert_equal 1, spy.ready_predicate_call_count
      assert_equal ["b"], spy.two_last_called_with.args
      assert_true spy.ready_predicate_called?
    end
  end
end
