require 'assert'

require 'assert/view/base'
require 'assert/suite'

module Assert::View

  class BaseTest < Assert::Context
    desc "the view base"
    setup do
      @view = Assert::View::Base.new(Assert::Suite.new, StringIO.new("", "w+"))
    end
    subject{ @view }

    INSTANCE_METHODS = [
      :render, :print_result
    ]
    INSTANCE_METHODS.each do |method|
      should "respond to the instance method ##{method}" do
        assert_respond_to subject, method
      end
    end

  end

end
