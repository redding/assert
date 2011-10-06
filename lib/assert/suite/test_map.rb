require 'assert/suite/context_info'

class Assert::Suite

  class TestMap

    attr_reader :context_info

    def initialize
      @context_info = []
      @test_name_map = {}
    end

    def context(klass, caller_info)
      @context_info << ContextInfo.new(klass, caller_info)
    end

    def <<(test_name)
      @test_name_map[test_name.to_s] = @context_info.last
    end

    def context_info(test_name)
      @test_name_map[test_name.to_s]
    end

  end

end
