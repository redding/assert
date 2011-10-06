class Assert::Suite

  class ContextInfo

    attr_reader :klass, :file

    def initialize(klass, caller_info)
      @klass = klass
      @file = caller_info.first.gsub(/\:[0-9]+$/, '')
    end

  end

end
