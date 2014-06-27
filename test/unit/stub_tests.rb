require 'assert'
require 'assert/stub'

class Assert::Stub

  class UnitTests < Assert::Context
    desc "Assert::Stub"
    setup do
      @myclass = Class.new do
        def mymeth; 'meth'; end
        def myval(val); val; end
        def myargs(*args); args; end
        def myvalargs(val1, val2, *args); [val1, val2, args]; end
        def myblk(&block); block.call; end
      end
      @myobj = @myclass.new

      @stub = Assert::Stub.new(@myobj, :mymeth)
    end
    subject{ @stub }

    should have_readers :method_name, :name, :do
    should have_writers :do
    should have_cmeths :key

    should "generate a key given an object and method name" do
      obj = @myobj
      meth = :mymeth
      assert_equal "--#{obj.object_id}--#{meth}--", Assert::Stub.key(obj, meth)
    end

    should "know its names" do
      assert_equal 'mymeth', subject.method_name
      assert_equal "__assert_stub__#{subject.method_name}", subject.name
    end

    should "complain when called if no do block was given" do
      assert_raises Assert::NotStubbedError do
        @myobj.mymeth
      end

      subject.do = proc{ 'mymeth' }
      assert_nothing_raised do
        @myobj.mymeth
      end

      assert_nothing_raised do
        Assert::Stub.new(@myobj, :mymeth){ 'mymeth' }
      end
    end

    should "complain if stubbing a method that the object doesn't respond to" do
      assert_raises Assert::StubError do
        Assert::Stub.new(@myobj, :some_other_meth)
      end
    end

    should "complain if stubbed and called with no `do` proc given" do
      assert_raises(Assert::NotStubbedError){ @myobj.mymeth }
    end

    should "complain if stubbed and called with mismatched arity" do
      Assert::Stub.new(@myobj, :myval){ 'myval' }
      assert_raises(Assert::StubArityError){ @myobj.myval }
      assert_nothing_raised { @myobj.myval(1) }
      assert_raises(Assert::StubArityError){ @myobj.myval(1,2) }

      Assert::Stub.new(@myobj, :myargs){ 'myargs' }
      assert_nothing_raised { @myobj.myargs }
      assert_nothing_raised { @myobj.myargs(1) }
      assert_nothing_raised { @myobj.myargs(1,2) }

      Assert::Stub.new(@myobj, :myvalargs){ 'myvalargs' }
      assert_raises(Assert::StubArityError){ @myobj.myvalargs }
      assert_raises(Assert::StubArityError){ @myobj.myvalargs(1) }
      assert_nothing_raised { @myobj.myvalargs(1,2) }
      assert_nothing_raised { @myobj.myvalargs(1,2,3) }
    end

    should "complain if stubbed with mismatched arity" do
      assert_raises(Assert::StubArityError) do
        Assert::Stub.new(@myobj, :myval).with(){ 'myval' }
      end
      assert_raises(Assert::StubArityError) do
        Assert::Stub.new(@myobj, :myval).with(1,2){ 'myval' }
      end
      assert_nothing_raised do
        Assert::Stub.new(@myobj, :myval).with(1){ 'myval' }
      end

      assert_nothing_raised do
        Assert::Stub.new(@myobj, :myargs).with(){ 'myargs' }
      end
      assert_nothing_raised do
        Assert::Stub.new(@myobj, :myargs).with(1,2){ 'myargs' }
      end
      assert_nothing_raised do
        Assert::Stub.new(@myobj, :myargs).with(1){ 'myargs' }
      end

      assert_raises(Assert::StubArityError) do
        Assert::Stub.new(@myobj, :myvalargs).with(){ 'myvalargs' }
      end
      assert_raises(Assert::StubArityError) do
        Assert::Stub.new(@myobj, :myvalargs).with(1){ 'myvalargs' }
      end
      assert_nothing_raised do
        Assert::Stub.new(@myobj, :myvalargs).with(1,2){ 'myvalargs' }
      end
      assert_nothing_raised do
        Assert::Stub.new(@myobj, :myvalargs).with(1,2,3){ 'myvalargs' }
      end
    end

    should "stub methods with no args" do
      subject.teardown

      assert_equal 'meth', @myobj.mymeth
      Assert::Stub.new(@myobj, :mymeth){ 'mymeth' }
      assert_equal 'mymeth', @myobj.mymeth
    end

    should "stub methods with required arg" do
      assert_equal 1, @myobj.myval(1)
      stub = Assert::Stub.new(@myobj, :myval){ |val| val.to_s }
      assert_equal '1', @myobj.myval(1)
      assert_equal '2', @myobj.myval(2)
      stub.with(2){ 'two' }
      assert_equal 'two', @myobj.myval(2)
    end

    should "stub methods with variable args" do
      assert_equal [1,2], @myobj.myargs(1,2)
      stub = Assert::Stub.new(@myobj, :myargs){ |*args| args.join(',') }
      assert_equal '1,2', @myobj.myargs(1,2)
      assert_equal '3,4,5', @myobj.myargs(3,4,5)
      stub.with(3,4,5){ 'three-four-five' }
      assert_equal 'three-four-five', @myobj.myargs(3,4,5)
    end

    should "stub methods with required args and variable args" do
      assert_equal [1,2, [3]], @myobj.myvalargs(1,2,3)
      stub = Assert::Stub.new(@myobj, :myvalargs){ |*args| args.join(',') }
      assert_equal '1,2,3', @myobj.myvalargs(1,2,3)
      assert_equal '3,4,5', @myobj.myvalargs(3,4,5)
      stub.with(3,4,5){ 'three-four-five' }
      assert_equal 'three-four-five', @myobj.myvalargs(3,4,5)
    end

    should "stub methods that yield blocks" do
      blkcalled = false
      blk = proc{ blkcalled = true }
      @myobj.myblk(&blk)
      assert_equal true, blkcalled

      blkcalled = false
      Assert::Stub.new(@myobj, :myblk){ blkcalled = 'true' }
      @myobj.myblk(&blk)
      assert_equal 'true', blkcalled
    end

    should "stub methods even if they are not local to the object" do
      mydelegatorclass = Class.new do
        def initialize(delegateclass)
          @delegate = delegateclass.new
        end
        def respond_to?(meth)
          @delegate.respond_to?(meth) || super
        end
        def method_missing(meth, *args, &block)
          respond_to?(meth) ? @delegate.send(meth, *args, &block) : super
        end
      end
      mydelegator = mydelegatorclass.new(@myclass)

      assert_equal [1,2,[3]], mydelegator.myvalargs(1,2,3)
      stub = Assert::Stub.new(mydelegator, :myvalargs){ |*args| args.inspect }
      assert_equal '[1, 2, 3]', mydelegator.myvalargs(1,2,3)
      assert_equal '[4, 5, 6]', mydelegator.myvalargs(4,5,6)
      stub.with(4,5,6){ 'four-five-six' }
      assert_equal 'four-five-six', mydelegator.myvalargs(4,5,6)
    end

    should "be removable" do
      assert_equal 1, @myobj.myval(1)
      stub = Assert::Stub.new(@myobj, :myval){ |val| val.to_s }
      assert_equal '1', @myobj.myval(1)
      stub.teardown
      assert_equal 1, @myobj.myval(1)
    end

  end

  class MutatingArgsStubTests < UnitTests
    desc "with args that are mutated after they've been used to stub"
    setup do
      @arg = ChangeHashObject.new

      @stub = Assert::Stub.new(@myobj, :myval)
      @stub.with(@arg){ true }

      @arg.change!
    end
    subject{ @stub }

    should "not raise a stub error when called" do
      assert_nothing_raised{ @stub.call(@arg) }
    end

  end

  class NullStubTests < UnitTests
    desc "NullStub"
    setup do
      @ns = NullStub.new
    end
    subject{ @ns }

    should have_imeths :teardown

  end

  class ChangeHashObject
    def initialize
      @value = nil
    end

    def hash
      @value.hash
    end

    def change!
      @value = 1
    end
  end

end
