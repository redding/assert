root_path = File.expand_path("../..", __FILE__)
if !$LOAD_PATH.include?(root_path)
  $LOAD_PATH.unshift(root_path)
end
require 'test/helper'

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

    should "be provided for the terminal view" do
      assert_respond_to Assert::View::Terminal, :options
      assert_respond_to Assert::View::Terminal.new("suite", "io"), :options
    end

  end

  class TerminalTest < BaseTest
    desc "for the terminal view"
    setup{ ViewOptions.down }
    subject do
      Assert::View::Terminal.options
    end

    teardown{ ViewOptions.up }

    should "be an Options::Base object" do
      assert_kind_of Assert::Options::Base, Assert::View::Terminal.options
    end

    should "default the styled option" do
      assert_equal false, subject.styled
    end

    should "default its result abbreviations" do
      assert_equal '.',   subject.passed_abbrev
      assert_equal 'F',   subject.failed_abbrev
      assert_equal 'I',   subject.ignored_abbrev
      assert_equal 'S',   subject.skipped_abbrev
      assert_equal 'E',   subject.errored_abbrev
    end

    should "default its result styles" do
      assert_equal :green,   subject.passed_styles
      assert_equal :red,     subject.failed_styles
      assert_equal :magenta, subject.ignored_styles
      assert_equal :cyan,    subject.skipped_styles
      assert_equal :yellow,  subject.errored_styles
    end

  end

end


# .assert

# Assert::View::Terminal.options do
#   color nil
#   pass_abbrev 'P'
#   fail_styles :red, :bghite, :bold
# end
