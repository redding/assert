class Assert::Suite

  class ContextInfo

    attr_reader :klass, :file

    def initialize(klass, caller_info=nil)
      @klass = klass
      @file = if caller_info
        caller_info.first.gsub(/\:[0-9]+$/, '')
      end
    end

  end

end
