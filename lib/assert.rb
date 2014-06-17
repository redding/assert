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

  def self.stubs
    @stubs ||= {}
  end

  def self.stub(*args, &block)
    (self.stubs[Assert::Stub.key(*args)] ||= Assert::Stub.new(*args)).tap do |s|
      s.do = block
    end
  end

  def self.unstub(*args)
    (self.stubs.delete(Assert::Stub.key(*args)) || Assert::Stub::NullStub.new).teardown
  end

  def self.unstub!
    self.stubs.keys.each{ |key| self.stubs.delete(key).teardown }
  end

  class Context

    teardown{ Assert.unstub! } # unstub all stubs automatically

  end

end
