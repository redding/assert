require 'assert'

require 'assert/result_set'
require 'assert/result'
require 'assert/view/base'

class FakeView < Assert::View::Base
  attr_accessor :printed

  def initialize(suite, output_io)
    super
    self.printed = []
  end

  def handle_runtime_result(result)
    self.printed.push(result)
  end

end

class Assert::ResultSet

  class BasicTest < Assert::Context
    desc "Assert result set"
    setup do
      @result_set = Assert::ResultSet.new
    end
    subject { @result_set }

    should have_accessor :view
  end


  class ViewTest < BasicTest
    desc "view"
    setup do
      @view_s = ""
      @view = @result_set.view = FakeView.new(nil, StringIO.new(@view_s, "w+"))

      @pass_result = Assert::Result::Pass.new("test", "pass", [])
      @result_set << @pass_result
      @fail_result = Assert::Result::Fail.new("test", "fail", [])
      @result_set << @fail_result
      @skip_result = Assert::Result::Skip.new("test", Assert::Result::TestSkipped.new)
      @result_set << @skip_result
      @error_result = Assert::Result::Error.new("test", RuntimeError.new)
      @result_set << @error_result
    end
    subject{ @view }

    should "have 'printed' 1 pass result" do
      pass_results = @view.printed.reject{|r| !r.pass? }
      assert_equal 1, pass_results.size
      assert_kind_of Assert::Result::Pass, pass_results.first
      assert_equal @pass_result.test_name, pass_results.first.test_name
      assert_equal @pass_result.message, pass_results.first.message
    end
    should "have 'printed' 1 fail result" do
      fail_results = @view.printed.reject{|r| !r.fail? }
      assert_equal 1, fail_results.size
      assert_kind_of Assert::Result::Fail, fail_results.first
      assert_equal @fail_result.test_name, fail_results.first.test_name
      assert_equal @fail_result.message, fail_results.first.message
    end
    should "have 'printed' 1 skip result" do
      skip_results = @view.printed.reject{|r| !r.skip? }
      assert_equal 1, skip_results.size
      assert_kind_of Assert::Result::Skip, skip_results.first
      assert_equal @skip_result.test_name, skip_results.first.test_name
      assert_equal @skip_result.message, skip_results.first.message
    end
    should "have 'printed' 1 error result" do
      error_results = @view.printed.reject{|r| !r.error? }
      assert_equal 1, error_results.size
      assert_kind_of Assert::Result::Error, error_results.first
      assert_equal @error_result.test_name, error_results.first.test_name
      assert_equal @error_result.message, error_results.first.message
    end

  end

end
