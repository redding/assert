require 'assert/view/terminal'
require 'assert/view/helpers/ansi'

module Assert

  # define an Assert::View:Terminal view that renders ansi output using the
  # 'assert.ansi' template and setting up some styling defaults
  class AnsiTerminal < View::Terminal

    helper View::Helpers::AnsiStyles
    options do
      default_template        'assert.ansi'
      default_styled          false
      default_passed_styles   :green
      default_failed_styles   :red, :bold
      default_errored_styles  :yellow, :bold
      default_skipped_styles  :cyan
      default_ignored_styles  :magenta
    end

  end

  # Setup the above view, rendering on $stdout, as the default view for assert
  # (override in user or package helpers)
  options do
    default_view AnsiTerminal.new($stdout)
  end

  # setup the global Assert.view method
  class << self
    def view; self.options.view; end
  end

end
