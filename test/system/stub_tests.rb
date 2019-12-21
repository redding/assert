require "assert"
require "assert/stub"

class Assert::Stub
  class SystemTests < Assert::Context
    desc "Assert::Stub"
  end

  class InstanceTests < SystemTests
    desc "for instance methods"
    setup do
      @instance = TestClass.new
      Assert.stub(@instance, :noargs){ "default" }
      Assert.stub(@instance, :noargs).with{ "none" }

      Assert.stub(@instance, :withargs){ "default" }
      Assert.stub(@instance, :withargs).with(1){ "one" }

      Assert.stub(@instance, :anyargs){ "default" }
      Assert.stub(@instance, :anyargs).with(1, 2){ "one-two" }

      Assert.stub(@instance, :minargs){ "default" }
      Assert.stub(@instance, :minargs).with(1, 2){ "one-two" }
      Assert.stub(@instance, :minargs).with(1, 2, 3){ "one-two-three" }

      Assert.stub(@instance, :withblock){ "default" }
    end
    subject{ @instance }

    should "allow stubbing a method that doesn't take args" do
      assert_equal "none", subject.noargs
    end

    should "allow stubbing a method that takes args" do
      assert_equal "one",     subject.withargs(1)
      assert_equal "default", subject.withargs(2)
    end

    should "allow stubbing a method that takes any args" do
      assert_equal "default", subject.anyargs
      assert_equal "default", subject.anyargs(1)
      assert_equal "one-two", subject.anyargs(1, 2)
    end

    should "allow stubbing a method that takes a minimum number of args" do
      assert_equal "one-two",       subject.minargs(1, 2)
      assert_equal "one-two-three", subject.minargs(1, 2, 3)
      assert_equal "default",       subject.minargs(1, 2, 4)
      assert_equal "default",       subject.minargs(1, 2, 3, 4)
    end

    should "allow stubbing a method that takes a block" do
      assert_equal "default", subject.withblock
      assert_equal "default", subject.withblock{ "my-block" }
    end

    should "not allow stubbing methods with invalid arity" do
      assert_raises{ Assert.stub(subject, :noargs).with(1){ } }

      assert_raises{ Assert.stub(subject, :withargs).with{ } }
      assert_raises{ Assert.stub(subject, :withargs).with(1, 2){ } }

      assert_raises{ Assert.stub(subject, :minargs).with{ } }
      assert_raises{ Assert.stub(subject, :minargs).with(1){ } }

      assert_raises{ Assert.stub(subject, :withblock).with(1){ } }
    end

    should "not allow calling methods with invalid arity" do
      assert_raises{ subject.noargs(1) }

      assert_raises{ subject.withargs }
      assert_raises{ subject.withargs(1, 2) }

      assert_raises{ subject.minargs }
      assert_raises{ subject.minargs(1) }

      assert_raises{ subject.withblock(1) }
    end
  end

  class ClassTests < SystemTests
    desc "for singleton methods on a class"
    setup do
      @class = TestClass
      Assert.stub(@class, :noargs){ "default" }
      Assert.stub(@class, :noargs).with{ "none" }

      Assert.stub(@class, :withargs){ "default" }
      Assert.stub(@class, :withargs).with(1){ "one" }

      Assert.stub(@class, :anyargs){ "default" }
      Assert.stub(@class, :anyargs).with(1, 2){ "one-two" }

      Assert.stub(@class, :minargs){ "default" }
      Assert.stub(@class, :minargs).with(1, 2){ "one-two" }
      Assert.stub(@class, :minargs).with(1, 2, 3){ "one-two-three" }

      Assert.stub(@class, :withblock){ "default" }
    end
    subject{ @class }

    should "allow stubbing a method that doesn't take args" do
      assert_equal "none", subject.noargs
    end

    should "allow stubbing a method that takes args" do
      assert_equal "one",     subject.withargs(1)
      assert_equal "default", subject.withargs(2)
    end

    should "allow stubbing a method that takes any args" do
      assert_equal "default", subject.anyargs
      assert_equal "default", subject.anyargs(1)
      assert_equal "one-two", subject.anyargs(1, 2)
    end

    should "allow stubbing a method that takes a minimum number of args" do
      assert_equal "one-two",       subject.minargs(1, 2)
      assert_equal "one-two-three", subject.minargs(1, 2, 3)
      assert_equal "default",       subject.minargs(1, 2, 4)
      assert_equal "default",       subject.minargs(1, 2, 3, 4)
    end

    should "allow stubbing a method that takes a block" do
      assert_equal "default", subject.withblock
      assert_equal "default", subject.withblock{ "my-block" }
    end

    should "not allow stubbing methods with invalid arity" do
      assert_raises{ Assert.stub(subject, :noargs).with(1){ } }

      assert_raises{ Assert.stub(subject, :withargs).with{ } }
      assert_raises{ Assert.stub(subject, :withargs).with(1, 2){ } }

      assert_raises{ Assert.stub(subject, :minargs).with{ } }
      assert_raises{ Assert.stub(subject, :minargs).with(1){ } }

      assert_raises{ Assert.stub(subject, :withblock).with(1){ } }
    end

    should "not allow calling methods with invalid arity" do
      assert_raises{ subject.noargs(1) }

      assert_raises{ subject.withargs }
      assert_raises{ subject.withargs(1, 2) }

      assert_raises{ subject.minargs }
      assert_raises{ subject.minargs(1) }

      assert_raises{ subject.withblock(1) }
    end
  end

  class ModuleTests < SystemTests
    desc "for singleton methods on a module"
    setup do
      @module = TestModule
      Assert.stub(@module, :noargs){ "default" }
      Assert.stub(@module, :noargs).with{ "none" }

      Assert.stub(@module, :withargs){ "default" }
      Assert.stub(@module, :withargs).with(1){ "one" }

      Assert.stub(@module, :anyargs){ "default" }
      Assert.stub(@module, :anyargs).with(1, 2){ "one-two" }

      Assert.stub(@module, :minargs){ "default" }
      Assert.stub(@module, :minargs).with(1, 2){ "one-two" }
      Assert.stub(@module, :minargs).with(1, 2, 3){ "one-two-three" }

      Assert.stub(@module, :withblock){ "default" }
    end
    subject{ @module }

    should "allow stubbing a method that doesn't take args" do
      assert_equal "none", subject.noargs
    end

    should "allow stubbing a method that takes args" do
      assert_equal "one",     subject.withargs(1)
      assert_equal "default", subject.withargs(2)
    end

    should "allow stubbing a method that takes any args" do
      assert_equal "default", subject.anyargs
      assert_equal "default", subject.anyargs(1)
      assert_equal "one-two", subject.anyargs(1, 2)
    end

    should "allow stubbing a method that takes a minimum number of args" do
      assert_equal "one-two",       subject.minargs(1, 2)
      assert_equal "one-two-three", subject.minargs(1, 2, 3)
      assert_equal "default",       subject.minargs(1, 2, 4)
      assert_equal "default",       subject.minargs(1, 2, 3, 4)
    end

    should "allow stubbing a method that takes a block" do
      assert_equal "default", subject.withblock
      assert_equal "default", subject.withblock{ "my-block" }
    end

    should "not allow stubbing methods with invalid arity" do
      assert_raises{ Assert.stub(subject, :noargs).with(1){ } }

      assert_raises{ Assert.stub(subject, :withargs).with{ } }
      assert_raises{ Assert.stub(subject, :withargs).with(1, 2){ } }

      assert_raises{ Assert.stub(subject, :minargs).with{ } }
      assert_raises{ Assert.stub(subject, :minargs).with(1){ } }

      assert_raises{ Assert.stub(subject, :withblock).with(1){ } }
    end

    should "not allow calling methods with invalid arity" do
      assert_raises{ subject.noargs(1) }

      assert_raises{ subject.withargs }
      assert_raises{ subject.withargs(1, 2) }

      assert_raises{ subject.minargs }
      assert_raises{ subject.minargs(1) }

      assert_raises{ subject.withblock(1) }
    end
  end

  class ExtendedTests < SystemTests
    desc "for extended methods"
    setup do
      @class = Class.new{ extend TestMixin }
      Assert.stub(@class, :noargs){ "default" }
      Assert.stub(@class, :noargs).with{ "none" }

      Assert.stub(@class, :withargs){ "default" }
      Assert.stub(@class, :withargs).with(1){ "one" }

      Assert.stub(@class, :anyargs){ "default" }
      Assert.stub(@class, :anyargs).with(1, 2){ "one-two" }

      Assert.stub(@class, :minargs){ "default" }
      Assert.stub(@class, :minargs).with(1, 2){ "one-two" }
      Assert.stub(@class, :minargs).with(1, 2, 3){ "one-two-three" }

      Assert.stub(@class, :withblock){ "default" }
    end
    subject{ @class }

    should "allow stubbing a method that doesn't take args" do
      assert_equal "none", subject.noargs
    end

    should "allow stubbing a method that takes args" do
      assert_equal "one",     subject.withargs(1)
      assert_equal "default", subject.withargs(2)
    end

    should "allow stubbing a method that takes any args" do
      assert_equal "default", subject.anyargs
      assert_equal "default", subject.anyargs(1)
      assert_equal "one-two", subject.anyargs(1, 2)
    end

    should "allow stubbing a method that takes a minimum number of args" do
      assert_equal "one-two",       subject.minargs(1, 2)
      assert_equal "one-two-three", subject.minargs(1, 2, 3)
      assert_equal "default",       subject.minargs(1, 2, 4)
      assert_equal "default",       subject.minargs(1, 2, 3, 4)
    end

    should "allow stubbing a method that takes a block" do
      assert_equal "default", subject.withblock
      assert_equal "default", subject.withblock{ "my-block" }
    end

    should "not allow stubbing methods with invalid arity" do
      assert_raises{ Assert.stub(subject, :noargs).with(1){ } }

      assert_raises{ Assert.stub(subject, :withargs).with{ } }
      assert_raises{ Assert.stub(subject, :withargs).with(1, 2){ } }

      assert_raises{ Assert.stub(subject, :minargs).with{ } }
      assert_raises{ Assert.stub(subject, :minargs).with(1){ } }

      assert_raises{ Assert.stub(subject, :withblock).with(1){ } }
    end

    should "not allow calling methods with invalid arity" do
      assert_raises{ subject.noargs(1) }

      assert_raises{ subject.withargs }
      assert_raises{ subject.withargs(1, 2) }

      assert_raises{ subject.minargs }
      assert_raises{ subject.minargs(1) }

      assert_raises{ subject.withblock(1) }
    end
  end

  class IncludedTests < SystemTests
    desc "for an included method"
    setup do
      @class = Class.new{ include TestMixin }
      @instance = @class.new
      Assert.stub(@instance, :noargs){ "default" }
      Assert.stub(@instance, :noargs).with{ "none" }

      Assert.stub(@instance, :withargs){ "default" }
      Assert.stub(@instance, :withargs).with(1){ "one" }

      Assert.stub(@instance, :anyargs){ "default" }
      Assert.stub(@instance, :anyargs).with(1, 2){ "one-two" }

      Assert.stub(@instance, :minargs){ "default" }
      Assert.stub(@instance, :minargs).with(1, 2){ "one-two" }
      Assert.stub(@instance, :minargs).with(1, 2, 3){ "one-two-three" }

      Assert.stub(@instance, :withblock){ "default" }
    end
    subject{ @instance }

    should "allow stubbing a method that doesn't take args" do
      assert_equal "none", subject.noargs
    end

    should "allow stubbing a method that takes args" do
      assert_equal "one",     subject.withargs(1)
      assert_equal "default", subject.withargs(2)
    end

    should "allow stubbing a method that takes any args" do
      assert_equal "default", subject.anyargs
      assert_equal "default", subject.anyargs(1)
      assert_equal "one-two", subject.anyargs(1, 2)
    end

    should "allow stubbing a method that takes a minimum number of args" do
      assert_equal "one-two",       subject.minargs(1, 2)
      assert_equal "one-two-three", subject.minargs(1, 2, 3)
      assert_equal "default",       subject.minargs(1, 2, 4)
      assert_equal "default",       subject.minargs(1, 2, 3, 4)
    end

    should "allow stubbing a method that takes a block" do
      assert_equal "default", subject.withblock
      assert_equal "default", subject.withblock{ "my-block" }
    end

    should "not allow stubbing methods with invalid arity" do
      assert_raises{ Assert.stub(subject, :noargs).with(1){ } }

      assert_raises{ Assert.stub(subject, :withargs).with{ } }
      assert_raises{ Assert.stub(subject, :withargs).with(1, 2){ } }

      assert_raises{ Assert.stub(subject, :minargs).with{ } }
      assert_raises{ Assert.stub(subject, :minargs).with(1){ } }

      assert_raises{ Assert.stub(subject, :withblock).with(1){ } }
    end

    should "not allow calling methods with invalid arity" do
      assert_raises{ subject.noargs(1) }

      assert_raises{ subject.withargs }
      assert_raises{ subject.withargs(1, 2) }

      assert_raises{ subject.minargs }
      assert_raises{ subject.minargs(1) }

      assert_raises{ subject.withblock(1) }
    end
  end

  class InheritedClassTests < SystemTests
    desc "for an inherited class method"
    setup do
      @class = Class.new(TestClass)
      Assert.stub(@class, :noargs){ "default" }
      Assert.stub(@class, :noargs).with{ "none" }

      Assert.stub(@class, :withargs){ "default" }
      Assert.stub(@class, :withargs).with(1){ "one" }

      Assert.stub(@class, :anyargs){ "default" }
      Assert.stub(@class, :anyargs).with(1, 2){ "one-two" }

      Assert.stub(@class, :minargs){ "default" }
      Assert.stub(@class, :minargs).with(1, 2){ "one-two" }
      Assert.stub(@class, :minargs).with(1, 2, 3){ "one-two-three" }

      Assert.stub(@class, :withblock){ "default" }
    end
    subject{ @class }

    should "allow stubbing a method that doesn't take args" do
      assert_equal "none", subject.noargs
    end

    should "allow stubbing a method that takes args" do
      assert_equal "one",     subject.withargs(1)
      assert_equal "default", subject.withargs(2)
    end

    should "allow stubbing a method that takes any args" do
      assert_equal "default", subject.anyargs
      assert_equal "default", subject.anyargs(1)
      assert_equal "one-two", subject.anyargs(1, 2)
    end

    should "allow stubbing a method that takes a minimum number of args" do
      assert_equal "one-two",       subject.minargs(1, 2)
      assert_equal "one-two-three", subject.minargs(1, 2, 3)
      assert_equal "default",       subject.minargs(1, 2, 4)
      assert_equal "default",       subject.minargs(1, 2, 3, 4)
    end

    should "allow stubbing a method that takes a block" do
      assert_equal "default", subject.withblock
      assert_equal "default", subject.withblock{ "my-block" }
    end

    should "not allow stubbing methods with invalid arity" do
      assert_raises{ Assert.stub(subject, :noargs).with(1){ } }

      assert_raises{ Assert.stub(subject, :withargs).with{ } }
      assert_raises{ Assert.stub(subject, :withargs).with(1, 2){ } }

      assert_raises{ Assert.stub(subject, :minargs).with{ } }
      assert_raises{ Assert.stub(subject, :minargs).with(1){ } }

      assert_raises{ Assert.stub(subject, :withblock).with(1){ } }
    end

    should "not allow calling methods with invalid arity" do
      assert_raises{ subject.noargs(1) }

      assert_raises{ subject.withargs }
      assert_raises{ subject.withargs(1, 2) }

      assert_raises{ subject.minargs }
      assert_raises{ subject.minargs(1) }

      assert_raises{ subject.withblock(1) }
    end
  end

  class InheritedInstanceTests < SystemTests
    desc "for an inherited instance method"
    setup do
      @class = Class.new(TestClass)
      @instance = @class.new
      Assert.stub(@instance, :noargs){ "default" }
      Assert.stub(@instance, :noargs).with{ "none" }

      Assert.stub(@instance, :withargs){ "default" }
      Assert.stub(@instance, :withargs).with(1){ "one" }

      Assert.stub(@instance, :anyargs){ "default" }
      Assert.stub(@instance, :anyargs).with(1, 2){ "one-two" }

      Assert.stub(@instance, :minargs){ "default" }
      Assert.stub(@instance, :minargs).with(1, 2){ "one-two" }
      Assert.stub(@instance, :minargs).with(1, 2, 3){ "one-two-three" }

      Assert.stub(@instance, :withblock){ "default" }
    end
    subject{ @instance }

    should "allow stubbing a method that doesn't take args" do
      assert_equal "none", subject.noargs
    end

    should "allow stubbing a method that takes args" do
      assert_equal "one",     subject.withargs(1)
      assert_equal "default", subject.withargs(2)
    end

    should "allow stubbing a method that takes any args" do
      assert_equal "default", subject.anyargs
      assert_equal "default", subject.anyargs(1)
      assert_equal "one-two", subject.anyargs(1, 2)
    end

    should "allow stubbing a method that takes a minimum number of args" do
      assert_equal "one-two",       subject.minargs(1, 2)
      assert_equal "one-two-three", subject.minargs(1, 2, 3)
      assert_equal "default",       subject.minargs(1, 2, 4)
      assert_equal "default",       subject.minargs(1, 2, 3, 4)
    end

    should "allow stubbing a method that takes a block" do
      assert_equal "default", subject.withblock
      assert_equal "default", subject.withblock{ "my-block" }
    end

    should "not allow stubbing methods with invalid arity" do
      assert_raises{ Assert.stub(subject, :noargs).with(1){ } }

      assert_raises{ Assert.stub(subject, :withargs).with{ } }
      assert_raises{ Assert.stub(subject, :withargs).with(1, 2){ } }

      assert_raises{ Assert.stub(subject, :minargs).with{ } }
      assert_raises{ Assert.stub(subject, :minargs).with(1){ } }

      assert_raises{ Assert.stub(subject, :withblock).with(1){ } }
    end

    should "not allow calling methods with invalid arity" do
      assert_raises{ subject.noargs(1) }

      assert_raises{ subject.withargs }
      assert_raises{ subject.withargs(1, 2) }

      assert_raises{ subject.minargs }
      assert_raises{ subject.minargs(1) }

      assert_raises{ subject.withblock(1) }
    end
  end

  class DelegateClassTests < SystemTests
    desc "a class that delegates another object"
    setup do
      @class = DelegateClass
      Assert.stub(@class, :noargs){ "default" }
      Assert.stub(@class, :noargs).with{ "none" }

      Assert.stub(@class, :withargs){ "default" }
      Assert.stub(@class, :withargs).with(1){ "one" }

      Assert.stub(@class, :anyargs){ "default" }
      Assert.stub(@class, :anyargs).with(1, 2){ "one-two" }

      Assert.stub(@class, :minargs){ "default" }
      Assert.stub(@class, :minargs).with(1, 2){ "one-two" }
      Assert.stub(@class, :minargs).with(1, 2, 3){ "one-two-three" }

      Assert.stub(@class, :withblock){ "default" }
    end
    subject{ @class }

    should "allow stubbing a method that doesn't take args" do
      assert_equal "none", subject.noargs
    end

    should "allow stubbing a method that takes args" do
      assert_equal "one",     subject.withargs(1)
      assert_equal "default", subject.withargs(2)
    end

    should "allow stubbing a method that takes any args" do
      assert_equal "default", subject.anyargs
      assert_equal "default", subject.anyargs(1)
      assert_equal "one-two", subject.anyargs(1, 2)
    end

    should "allow stubbing a method that takes a minimum number of args" do
      assert_equal "one-two",       subject.minargs(1, 2)
      assert_equal "one-two-three", subject.minargs(1, 2, 3)
      assert_equal "default",       subject.minargs(1, 2, 4)
      assert_equal "default",       subject.minargs(1, 2, 3, 4)
    end

    should "allow stubbing a method that takes a block" do
      assert_equal "default", subject.withblock
      assert_equal "default", subject.withblock{ "my-block" }
    end

    should "allow stubbing methods with invalid arity" do
      assert_nothing_raised{ Assert.stub(subject, :noargs).with(1){ } }

      assert_nothing_raised{ Assert.stub(subject, :withargs).with{ } }
      assert_nothing_raised{ Assert.stub(subject, :withargs).with(1, 2){ } }

      assert_nothing_raised{ Assert.stub(subject, :minargs).with{ } }
      assert_nothing_raised{ Assert.stub(subject, :minargs).with(1){ } }

      assert_nothing_raised{ Assert.stub(subject, :withblock).with(1){ } }
    end

    should "allow calling methods with invalid arity" do
      assert_nothing_raised{ subject.noargs(1) }

      assert_nothing_raised{ subject.withargs }
      assert_nothing_raised{ subject.withargs(1, 2) }

      assert_nothing_raised{ subject.minargs }
      assert_nothing_raised{ subject.minargs(1) }

      assert_nothing_raised{ subject.withblock(1) }
    end
  end

  class DelegateInstanceTests < SystemTests
    desc "an instance that delegates another object"
    setup do
      @instance = DelegateClass.new
      Assert.stub(@instance, :noargs){ "default" }
      Assert.stub(@instance, :noargs).with{ "none" }

      Assert.stub(@instance, :withargs){ "default" }
      Assert.stub(@instance, :withargs).with(1){ "one" }

      Assert.stub(@instance, :anyargs){ "default" }
      Assert.stub(@instance, :anyargs).with(1, 2){ "one-two" }

      Assert.stub(@instance, :minargs){ "default" }
      Assert.stub(@instance, :minargs).with(1, 2){ "one-two" }
      Assert.stub(@instance, :minargs).with(1, 2, 3){ "one-two-three" }

      Assert.stub(@instance, :withblock){ "default" }
    end
    subject{ @instance }

    should "allow stubbing a method that doesn't take args" do
      assert_equal "none", subject.noargs
    end

    should "allow stubbing a method that takes args" do
      assert_equal "one",     subject.withargs(1)
      assert_equal "default", subject.withargs(2)
    end

    should "allow stubbing a method that takes any args" do
      assert_equal "default", subject.anyargs
      assert_equal "default", subject.anyargs(1)
      assert_equal "one-two", subject.anyargs(1, 2)
    end

    should "allow stubbing a method that takes a minimum number of args" do
      assert_equal "one-two",       subject.minargs(1, 2)
      assert_equal "one-two-three", subject.minargs(1, 2, 3)
      assert_equal "default",       subject.minargs(1, 2, 4)
      assert_equal "default",       subject.minargs(1, 2, 3, 4)
    end

    should "allow stubbing a method that takes a block" do
      assert_equal "default", subject.withblock
      assert_equal "default", subject.withblock{ "my-block" }
    end

    should "allow stubbing methods with invalid arity" do
      assert_nothing_raised{ Assert.stub(subject, :noargs).with(1){ } }

      assert_nothing_raised{ Assert.stub(subject, :withargs).with{ } }
      assert_nothing_raised{ Assert.stub(subject, :withargs).with(1, 2){ } }

      assert_nothing_raised{ Assert.stub(subject, :minargs).with{ } }
      assert_nothing_raised{ Assert.stub(subject, :minargs).with(1){ } }

      assert_nothing_raised{ Assert.stub(subject, :withblock).with(1){ } }
    end

    should "allow calling methods with invalid arity" do
      assert_nothing_raised{ subject.noargs(1) }

      assert_nothing_raised{ subject.withargs }
      assert_nothing_raised{ subject.withargs(1, 2) }

      assert_nothing_raised{ subject.minargs }
      assert_nothing_raised{ subject.minargs(1) }

      assert_nothing_raised{ subject.withblock(1) }
    end
  end

  class ParentAndChildClassTests < SystemTests
    desc "for a parent method stubbed on both the parent and child"
    setup do
      @parent_class = Class.new
      @child_class = Class.new(@parent_class)

      Assert.stub(@parent_class, :new){ "parent" }
      Assert.stub(@child_class, :new){ "child" }
    end

    should "allow stubbing the methods individually" do
      assert_equal "parent", @parent_class.new
      assert_equal "child", @child_class.new
    end
  end

  class TestClass
    def self.noargs; end
    def self.withargs(a); end
    def self.anyargs(*args); end
    def self.minargs(a, b, *args); end
    def self.withblock(&block); end

    def noargs; end
    def withargs(a); end
    def anyargs(*args); end
    def minargs(a, b, *args); end
    def withblock(&block); end
  end

  module TestModule
    def self.noargs; end
    def self.withargs(a); end
    def self.anyargs(*args); end
    def self.minargs(a, b, *args); end
    def self.withblock(&block); end
  end

  module TestMixin
    def noargs; end
    def withargs(a); end
    def anyargs(*args); end
    def minargs(a, b, *args); end
    def withblock(&block); end
  end

  class DelegateClass
    def self.respond_to?(*args)
      TestClass.respond_to?(*args) || super
    end

    def self.method_missing(name, *args, &block)
      TestClass.respond_to?(name) ? TestClass.send(name, *args, &block) : super
    end

    def initialize
      @delegate = TestClass.new
    end

    def respond_to?(*args)
      @delegate.respond_to?(*args) || super
    end

    def method_missing(name, *args, &block)
      @delegate.respond_to?(name) ? @delegate.send(name, *args, &block) : super
    end
  end
end
