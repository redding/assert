require 'assert/version'

require 'assert/config'
require 'assert/context'
require 'assert/runner'
require 'assert/stub'
require 'assert/suite'
require 'assert/utils'
require 'assert/view'

module Assert

  def self.config; @config ||= Config.new; end
  def self.configure; yield self.config if block_given?; end

  def self.view;   self.config.view;   end
  def self.suite;  self.config.suite;  end
  def self.runner; self.config.runner; end

  # unstub all stubs automatically (see stub.rb)
  class Context
    teardown{ Assert.unstub! }
  end

end

# Kernel#caller_locations polyfill for pre ruby 2.0.0
if RUBY_VERSION =~ /\A1\..+/ && !Kernel.respond_to?(:caller_locations)
  module Kernel
    def caller_locations(start = 1, length = nil)
      length ? caller[start, length] : caller[start..-1]
    end
  end
end
