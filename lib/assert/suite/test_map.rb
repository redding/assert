require 'assert/suite/context_info'

class Assert::Suite

  class TestMap

    attr_accessor :caller_info

    def initialize
      @test_name_map = {}
      @caller_info = nil
    end

    def caller_info=(caller_info)
      @caller_info = caller_info
    end

    def map(test_klass, test_name)
      @test_name_map[map_key(test_klass, test_name)] = ContextInfo.new(test_klass, @caller_info)
    end

    def context_info(test_klass, test_name)
      @test_name_map[map_key(test_klass, test_name)] || ContextInfo.new(test_klass)
    end

    def inspect
      [ "#{self.class}:#{self.object_id}",
        "mappings:",
        @test_name_map.keys.sort.collect do |k|
          "  #{k} => #{@test_name_map[k].inspect}"
        end.sort
      ].flatten.join("\n")
    end

    private

    def map_key(klass, test_name)
      "#{klass}##{test_name}"
    end

  end

end
