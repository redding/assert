require 'assert'
require 'assert/file_line'

class Assert::FileLine

  class UnitTests < Assert::Context
    desc "Assert::FileLine"
    setup do
      @file = "#{Factory.path}_tests.rb"
      @line = Factory.integer.to_s
    end
    subject{ Assert::FileLine }

    should have_imeths :parse

    should "know how to parse and init from a file line path string" do
      file_line_path = "#{@file}:#{@line}"
      file_line = subject.parse(file_line_path)

      assert_equal @file, file_line.file
      assert_equal @line, file_line.line
    end

  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @file_line = Assert::FileLine.new(@file, @line)
    end
    subject{ @file_line }

    should have_readers :file, :line

    should "know its file and line" do
      assert_equal @file, subject.file
      assert_equal @line, subject.line
    end

    should "know its string representation" do
      assert_equal "#{subject.file}:#{subject.line}", subject.to_s
    end

    should "know if it is equal to another file line" do
      yes = Assert::FileLine.new(@file, @line)
      no = Assert::FileLine.new("#{Factory.path}_tests.rb", Factory.integer.to_s)

      assert_equal     yes, subject
      assert_not_equal no,  subject
    end

  end

end
