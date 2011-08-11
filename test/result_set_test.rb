require 'test_belt'
require 'stringio'

require 'assert/result_set'
require 'assert/result'
require 'assert/view/base'

class Assert::ResultSet
  class BasicTest < Test::Unit::TestCase
    include TestBelt

    subject { Assert::ResultSet.new }
    before {
      @view_s = ""
      subject.view = Assert::View::Base.new(nil, StringIO.new(@view_s, "w+"))
      subject << Assert::Result::Pass.new("test", "pass", [])
      subject << Assert::Result::Fail.new("test", "fail", [])
      subject << Assert::Result::Skip.new("test", RuntimeError.new)
      subject << Assert::Result::Error.new("test", RuntimeError.new)
    }

    should have_accessor :view
  end
end
