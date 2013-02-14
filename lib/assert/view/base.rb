require 'assert/result'
require 'assert/options'

module Assert::View

  class Base

    # setup some default options for all views

    include Assert::Options
    options do
      default_pass_abbrev   '.'
      default_fail_abbrev   'F'
      default_ignore_abbrev 'I'
      default_skip_abbrev   'S'
      default_error_abbrev  'E'
    end

    # include a bunch of common helper methods

    require 'assert/view/helpers/common'
    include Helpers::Common

    attr_accessor :output_io

    def initialize(output_io, suite=nil)
      @output_io, @suite = output_io, suite
      @output_io.sync = true if @output_io.respond_to?(:sync=)
    end

    def view; self; end
    def suite; @suite || Assert.suite; end

    def fire(callback, *args)
      self.send(callback, *args)
    end

    # Callbacks

    # define callback handlers to output information.  handlers are
    # instance_eval'd in the scope of the view instance.  any stdout is captured
    # and sent to the io stream.

    # available callbacks from the runner:
    # * `before_load`: called at the beginning, before the suite is loaded
    # * `after_load`:  called after the suite is loaded, just before `on_start`
    #                  functionally equivalent to `on_start`
    # * `on_start`:    called when a loaded test suite starts running
    # * `before_test`: called before a test starts running
    #                  the test is passed as an arg
    # * `on_result`:   called when a running tests generates a result
    #                  the result is passed as an arg
    # * `after_test`:  called after a test finishes running
    #                  the test is passed as an arg
    # * `on_finish`:   called when the test suite is finished running

    def before_load;       end
    def after_load;        end
    def on_start;          end
    def before_test(test); end
    def on_result(result); end
    def after_test(test);  end
    def on_finish;         end

    # IO capture

    def puts(*args); @output_io.puts(*args); end
    def print(*args); @output_io.print(*args); end

  end

end
