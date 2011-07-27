require 'assert/result'

module Assert
  class Assertion

    attr_reader :statement
    attr_accessor :fail_msg

    def initialize(fail_msg="", &block)
      @value = nil
      @result = nil
      @fail_msg = fail_msg
      self.statement = block
    end

    def value
      @value ||= @statement.call
    end

    def result
      @result ||= begin
        if self.value.nil?
          Result::Skip.new
        elsif !!self.value
          Result::Pass.new
        else
          Result::Fail.new
        end
      rescue Exception => err
       Result::Error.new
      end
    end

    protected

    def statement=(value)
      raise ArgumentError if !value.kind_of?(::Proc)
      @value = nil
      @result = nil
      @statement = value
    end

  end
end