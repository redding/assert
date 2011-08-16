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

    should have_reader :suite
    should have_instance_methods :render, :handle_runtime_result, :options
    should have_class_method :options

  end

end
