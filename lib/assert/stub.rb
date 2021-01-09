# frozen_string_literal: true

require "much-stub"

module Assert
  def self.stubs
    MuchStub.stubs
  end

  def self.stub(*args, &block)
    MuchStub.stub(*args, &block)
  end

  def self.stub_on_call(*args, &block)
    MuchStub.stub_on_call(*args, &block)
  end

  def self.unstub(*args)
    MuchStub.unstub(*args)
  end

  def self.unstub!
    MuchStub.unstub!
  end

  def self.stub_send(*args, &block)
    orig_caller = caller_locations
    begin
      MuchStub.stub_send(*args, &block)
    rescue MuchStub::NotStubbedError => ex
      ex.set_backtrace(orig_caller.map(&:to_s))
      raise ex
    end
  end

  def self.stub_tap(*args, &block)
    MuchStub.tap(*args, &block)
  end

  def self.stub_tap_on_call(*args, &block)
    MuchStub.tap_on_call(*args, &block)
  end

  def self.stub_spy(*args, &block)
    MuchStub.spy(*args, &block)
  end

  StubCall = MuchStub::Call
  class StubCall
    def self.name
      super.gsub("MuchStub::Call", "Assert::StubCall")
    end

    def self.to_s
      super.gsub("MuchStub::Call", "Assert::StubCall")
    end

    def self.inspect
      super.gsub("MuchStub::Call", "Assert::StubCall")
    end

    def inspect
      super.gsub("MuchStub::Call", "Assert::StubCall")
    end
  end

  StubCallSpy = MuchStub::CallSpy
  class StubCallSpy
    def self.name
      super.gsub("MuchStub::CallSpy", "Assert::StubCallSpy")
    end

    def self.to_s
      super.gsub("MuchStub::CallSpy", "Assert::StubCallSpy")
    end

    def self.inspect
      super.gsub("MuchStub::CallSpy", "Assert::StubCallSpy")
    end

    # See MuchStub::CallSpy#inspect.
    def inspect
      "#<Assert::StubCallSpy:#{"0x0%x" % (__id__ << 1)}>"
    end
  end
end
