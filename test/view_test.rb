require 'test_belt'

require 'assert/view/base'
require 'assert/suite'

module Assert::View

  class BaseTest < Test::Unit::TestCase
    include TestBelt

    context "the view base"
    subject { Assert::View::Base.new(Assert::Suite.new, StringIO.new("", "w+")) }

    should have_instance_method :render, :print_result

    should "complain if you call its render method directly" do
      assert_raises NotImplementedError do
        subject.render
      end
    end

  end

end
