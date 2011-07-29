require 'assert/context'
require 'assert/runner'

module Assert

  # a flag to know if at_exit hook has been installed already
  @@at_exit_installed ||= false

  # the set of contexts to run
  @@suite = Suite.new

  class << self

    # access the suite
    def suite
      @@suite
    end

    # install at_exit hook (if needed) (runs at process exit)
    # this ensures the test suite won't run unitl all test files are loaded
    # (this is essentially a direct rip from Minitest)
    def autorun
      at_exit do
        # don't run if there was an exception
        next if $!

        # the order here is important. The at_exit handler must be
        # installed before anyone else gets a chance to install their
        # own, that way we can be assured that our exit will be last
        # to run (at_exit stacks).

        exit_code = nil
        at_exit { exit(false) if exit_code && exit_code != 0 }
        exit_code = Runner.new(suite, :output => $stdout).run
      end unless @@at_exit_installed
      @@at_exit_installed = true
    end

  end

end

Assert.autorun