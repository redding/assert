require 'assert/result'

module Assert
  class Assertion

    attr_reader :statement, :description

    def initialize(description="", &block)
      @description = description
      self.statement = block
      @result = nil
    end

    def result
      @result ||= statement_result
    end

    protected

    def statement=(value)
      raise ArgumentError if !value.kind_of?(::Proc)
      @statement = value
    end

    private

    def statement_result
      if @statement.call.nil?
        Result::Skip.new
      else
        begin
          !!@statement.call ? Result::Pass.new : Result::Fail.new
        rescue Exception => err
         Result::Error.new
        end
      end
    end

  end
end