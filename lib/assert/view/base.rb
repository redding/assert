require 'assert/result'
require 'assert/options'

require 'assert/view/renderer'
require 'assert/view/common'

module Assert::View

  class Base

    include Assert::Options
    options do
      default_pass_abbrev   '.'
      default_fail_abbrev   'F'
      default_ignore_abbrev 'I'
      default_skip_abbrev   'S'
      default_error_abbrev  'E'
    end

    # the Renderer defines the hooks and callbacks needed for the runner to
    # work with the view.  It provides:
    # * 'render': called by the runner to render the view
    # * 'self.helper': used to provide helper mixins to the renderer template
    # * 'self.template': used to define the template proc
    include Renderer

    # include a bunch of common view utility methods
    include Common

    attr_accessor :suite, :output_io, :runtime_result_callback

    def initialize(output_io, suite=Assert.suite)
      self.output_io = output_io
      self.suite     = suite
    end

    def view
      self
    end

    # should be called by the view template to start running the tests
    def run_tests(runner, &result_callback)
      self.runtime_result_callback = result_callback
      runner.call if runner
    end

    # callback used by the runner to notify the view of any new results
    def handle_runtime_result(result)
      self.runtime_result_callback.call(result) if self.runtime_result_callback
    end

  end

end
