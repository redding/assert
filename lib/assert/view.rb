require 'assert/config'
require 'assert/suite'
require 'assert/view_helpers'

module Assert

  module View

    # this method is used to bring in custom user-specific views
    # require views by passing either a full path to the view ruby file
    # or passing the name of a view installed in ~/.assert/views

    def self.require_user_view(view_name)
      views_file = File.expand_path(
        File.join("#{ENV['HOME']}/.assert/views", view_name, 'lib', view_name)
      )

      if File.exists?(view_name) || File.exists?(view_name + '.rb')
        require view_name
      elsif File.exists?(views_file + '.rb')
        require views_file
      else
        msg = "[WARN] Can't find or require #{view_name.inspect} view."
        msg << " Did you install it in `~/.assert/views`?" if !view_name.match(/\A\//)
        warn msg
      end
    end

    class Base
      include Assert::ViewHelpers

      # setup options and their default values

      option 'pass_abbrev',   '.'
      option 'fail_abbrev',   'F'
      option 'ignore_abbrev', 'I'
      option 'skip_abbrev',   'S'
      option 'error_abbrev',  'E'

      attr_reader :config, :suite

      def initialize(output_io, *args)
        @output_io = output_io
        @suite, @config = [
          args.last.kind_of?(Assert::Suite)  ? args.pop : nil,
          args.last.kind_of?(Assert::Config) ? args.pop : nil
        ]

        @output_io.sync = true if @output_io.respond_to?(:sync=)
      end

      def is_tty?
        !!@output_io.isatty
      end

      def view
        self
      end

      def config
        @config ||= Assert.config
      end

      def suite
        @suite ||= Assert.suite
      end

      def fire(callback, *args)
        self.send(callback, *args)
      end

      # Callbacks

      # define callback handlers to output information.  handlers are
      # instance_eval'd in the scope of the view instance.  any stdout is captured
      # and sent to the io stream.

      # available callbacks from the runner:
      # * `before_load`:  called at the beginning, before the suite is loaded
      # * `after_load`:   called after the suite is loaded, just before `on_start`
      #                   functionally equivalent to `on_start`
      # * `on_start`:     called when a loaded test suite starts running
      # * `before_test`:  called before a test starts running
      #                   the test is passed as an arg
      # * `on_result`:    called when a running tests generates a result
      #                   the result is passed as an arg
      # * `after_test`:   called after a test finishes running
      #                   the test is passed as an arg
      # * `on_finish`:    called when the test suite is finished running
      # * `on_interrupt`: called when the test suite is interrupted while running
      #                   the interrupt exception is passed as an arg

      def before_load(test_files); end
      def after_load;              end
      def on_start;                end
      def before_test(test);       end
      def on_result(result);       end
      def after_test(test);        end
      def on_finish;               end
      def on_interrupt(err);       end

      # IO capture

      def puts(*args); @output_io.puts(*args); end
      def print(*args); @output_io.print(*args); end

    end

  end

end
