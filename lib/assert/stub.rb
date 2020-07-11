require "much-stub"

module Assert
  def self.stubs
    MuchStub.stubs
  end

  def self.stub(*args, &block)
    MuchStub.stub(*args, &block)
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
    rescue MuchStub::NotStubbedError => err
      err.set_backtrace(orig_caller.map(&:to_s))
      raise err
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
end
