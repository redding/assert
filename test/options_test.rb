require 'assert'
require 'assert/options'

module Assert::Options

  class BaseTest < Assert::Context
    desc "user options class"
    setup { @base = Assert::Options::Base.new }
    subject { @base }

    should "write single values by making a method call w/ a single arg" do
      subject.a_value 1
      assert_equal 1, subject.a_value
    end

    should "read values by making a method call w/ no args" do
      assert_equal nil, subject.a_value
      subject.a_value "blah"
      assert_equal "blah", subject.a_value
    end

    should "write an array of values by making a method call w/ multiple args" do
      subject.a_value [1,2,3]
      subject.values 1,2,3
      assert_equal subject.a_value, subject.values
    end

    should "write default values using the 'default_' prefix" do
      assert_equal nil, subject.a_value
      subject.default_a_value "def"
      assert_equal "def", subject.default_a_value
      assert_equal "def", subject.a_value
      subject.a_value "changed"
      assert_equal "def", subject.default_a_value
      assert_equal "changed", subject.a_value
    end

    should "be provided for the terminal view" do
      assert_respond_to :options, Assert::View::Terminal
      assert_respond_to :options, Assert::View::Terminal.new("suite", "io")
    end

  end

end
