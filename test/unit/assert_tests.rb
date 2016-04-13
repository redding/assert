require 'assert'

require 'assert/config'
require 'assert/stub'

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
    setup do
      @orig_value = Factory.string
      @stub_value = Factory.string

      @myclass = Class.new do
        def initialize(value); @value = value; end
        def mymeth; @value; end
      end
      @myobj = @myclass.new(@orig_value)
    end

    should "build a stub" do
      stub1 = Assert.stub(@myobj, :mymeth)
      assert_kind_of Assert::Stub, stub1
    end

    should "lookup stubs that have been called before" do
      stub1 = Assert.stub(@myobj, :mymeth)
      stub2 = Assert.stub(@myobj, :mymeth)
      assert_same stub1, stub2
    end

    should "set the stub's do block if given a block" do
      Assert.stub(@myobj, :mymeth)
      assert_raises(NotStubbedError){ @myobj.mymeth }
      Assert.stub(@myobj, :mymeth){ @stub_value }
      assert_equal @stub_value, @myobj.mymeth
    end

    should "teardown stubs" do
      assert_equal @orig_value, @myobj.mymeth
      Assert.unstub(@myobj, :mymeth)
      assert_equal @orig_value, @myobj.mymeth

      assert_equal @orig_value, @myobj.mymeth
      Assert.stub(@myobj, :mymeth){ @stub_value }
      assert_equal @stub_value, @myobj.mymeth
      Assert.unstub(@myobj, :mymeth)
      assert_equal @orig_value, @myobj.mymeth
    end

    should "know and teardown all stubs" do
      assert_equal @orig_value, @myobj.mymeth

      Assert.stub(@myobj, :mymeth){ @stub_value }
      assert_equal @stub_value, @myobj.mymeth
      assert_equal 1, Assert.stubs.size

      Assert.unstub!
      assert_equal @orig_value, @myobj.mymeth
      assert_empty Assert.stubs
    end

    should "auto-unstub any stubs on teardown" do
      context_class = ::Factory.modes_off_context_class do
        setup do
          Assert.stub('1', :to_s){ 'one' }
        end
      end

      context_class.run_setups('scope')
      assert_equal 1, Assert.stubs.size

      context_class.run_teardowns('scope')
      assert_empty Assert.stubs
    end

    should "be able to call a stub's original method" do
      assert_raises(NotStubbedError){ Assert.stub_send(@myobj, :mymeth) }

      Assert.stub(@myobj, :mymeth){ @stub_value }

      assert_equal @stub_value, @myobj.mymeth
      assert_equal @orig_value, Assert.stub_send(@myobj, :mymeth)
    end

  end

end
