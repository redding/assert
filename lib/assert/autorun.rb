require 'assert/setup/all'

module Assert

  # a flag to know if at_exit hook has been installed already
  @@at_exit_installed ||= false

  # install at_exit hook (if needed) (runs at process exit)
  # this ensures the test suite won't run until all test files are loaded
  # (this is essentially a direct rip from Minitest)

  def self.autorun
    if !@@at_exit_installed
      self.view.fire(:before_load)

      at_exit do
        # don't run if there was an exception
        next if $!

        # the order here is important. The at_exit handler must be
        # installed before anyone else gets a chance to install their
        # own, that way we can be assured that our exit will be last
        # to run (at_exit stacks).

        exit_code = nil
        at_exit { exit(false) if exit_code && exit_code != 0 }

        self.view.fire(:after_load)
        self.runner.new(self.suite, self.view).run
      end

      @@at_exit_installed = true
    end
  end

end

