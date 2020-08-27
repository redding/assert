require "assert"
require "assert/file_line"

class Assert::FileLine
  class UnitTests < Assert::Context
    desc "Assert::FileLine"
    subject { Assert::FileLine }

    let(:file1) { "#{Factory.path}_tests.rb" }
    let(:line1) { Factory.integer.to_s }

    should have_imeths :parse

    should "know how to parse and init from a file line path string" do
      file_line_path = [
        "#{file1}:#{line1}",
        "#{file1}:#{line1} #{Factory.string}"
      ].sample
      file_line = subject.parse(file_line_path)

      assert_equal file1, file_line.file
      assert_equal line1, file_line.line
    end

    should "handle parsing bad data gracefully" do
      file_line = subject.parse(file1)
      assert_equal file1, file_line.file
      assert_equal "",    file_line.line

      file_line = subject.parse(line1)
      assert_equal line1, file_line.file
      assert_equal "",    file_line.line

      file_line = subject.parse("")
      assert_equal "", file_line.file
      assert_equal "", file_line.line

      file_line = subject.parse(nil)
      assert_equal "", file_line.file
      assert_equal "", file_line.line
    end
  end

  class InitTests < UnitTests
    desc "when init"
    subject { file_line1 }

    let(:file_line1) { Assert::FileLine.new(file1, line1) }

    should have_readers :file, :line

    should "know its file and line" do
      assert_equal file1, subject.file
      assert_equal line1, subject.line

      file_line = Assert::FileLine.new(file1)
      assert_equal file1, file_line.file
      assert_equal "",    file_line.line

      file_line = Assert::FileLine.new
      assert_equal "", file_line.file
      assert_equal "", file_line.line
    end

    should "know its string representation" do
      assert_equal "#{subject.file}:#{subject.line}", subject.to_s
    end

    should "know if it is equal to another file line" do
      yes = Assert::FileLine.new(file1, line1)
      no = Assert::FileLine.new("#{Factory.path}_tests.rb", Factory.integer.to_s)

      assert_equal     yes, subject
      assert_not_equal no,  subject
    end
  end
end
