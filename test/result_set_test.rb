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
      subject << Assert::Result::Pass.new
      subject << Assert::Result::Fail.new
      subject << Assert::Result::Skip.new
      subject << Assert::Result::Error.new
    }

    should have_accessor :view

    should "write result abbrevs to the view when they are added to the set" do
      assert_equal ".FSE", @view_s
    end

  end
end
