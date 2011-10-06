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
      @test_name_map[map_key(@context_info.last.klass, test_name)] = @context_info.last
    end

    def context_info(test_klass, test_name)
      @test_name_map[map_key(test_klass, test_name)]
    end

    private

    def map_key(klass, test_name)
      "#{klass}##{test_name}"
    end

  end

end
