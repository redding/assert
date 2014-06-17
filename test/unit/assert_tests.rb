require 'assert'

require 'assert/config'
require 'assert/stub'

module Assert

  class UnitTests < Assert::Context
    desc "Assert"
    subject { Assert }

    should have_imeths :config, :configure, :view, :suite, :runner
    should have_imeths :stub, :unstub

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
      @myclass = Class.new do
        def mymeth; 'meth'; end
      end
      @myobj = @myclass.new
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
      assert_raises(StubError){ @myobj.mymeth }
      Assert.stub(@myobj, :mymeth){ 'mymeth' }
      assert_equal 'mymeth', @myobj.mymeth
    end

    should "teardown stubs" do
      assert_equal 'meth', @myobj.mymeth
      Assert.unstub(@myobj, :mymeth)
      assert_equal 'meth', @myobj.mymeth

      assert_equal 'meth', @myobj.mymeth
      Assert.stub(@myobj, :mymeth){ 'mymeth' }
      assert_equal 'mymeth', @myobj.mymeth
      Assert.unstub(@myobj, :mymeth)
      assert_equal 'meth', @myobj.mymeth
    end

  end

end
