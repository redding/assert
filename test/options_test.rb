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
      assert_respond_to Assert::View::Terminal, :options
      assert_respond_to Assert::View::Terminal.new("suite", "io"), :options
    end

  end

  class TerminalTest < BaseTest
    desc "for the terminal view"
    subject do
      Assert::View::Terminal.options
    end

    should "be an Options::Base object" do
      assert_kind_of Assert::Options::Base, Assert::View::Terminal.options
    end

    should "default the styled option" do
      assert_equal false, subject.default_styled
    end

    should "default its result abbreviations" do
      assert_equal '.',   subject.default_passed_abbrev
      assert_equal 'F',   subject.default_failed_abbrev
      assert_equal 'I',   subject.default_ignored_abbrev
      assert_equal 'S',   subject.default_skipped_abbrev
      assert_equal 'E',   subject.default_errored_abbrev
    end

    should "default its result styles" do
      assert_equal :green,   subject.default_passed_styles
      assert_equal :red,     subject.default_failed_styles
      assert_equal :magenta, subject.default_ignored_styles
      assert_equal :cyan,    subject.default_skipped_styles
      assert_equal :yellow,  subject.default_errored_styles
    end

  end

end
