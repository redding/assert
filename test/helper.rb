# this file is automatically required when you run `assert`
# put any test helpers here

# add the root dir to the load path
ROOT_PATH = File.expand_path("../..", __FILE__)
$LOAD_PATH.unshift(ROOT_PATH)

# require pry for debugging (`binding.pry`)
require 'pry'
require 'test/support/factory'

# 1.8.7 backfills

# Array#sample
if !(a = Array.new).respond_to?(:sample) && a.respond_to?(:choice)
  class Array
    alias_method :sample, :choice
  end
end

class Assert::Test

  module TestHelpers

    def self.included(receiver)
      receiver.class_eval do
        setup do
          @test_run_results = []
          @run_callback = proc{ |result| @test_run_results << result }
        end
      end

      private

      def test_run_callback
        @run_callback
      end

      def test_run_results(type = nil)
        return @test_run_results if type.nil?
        @test_run_results.select{ |r| r.type == type }
      end

      def test_run_result_count(type = nil)
        test_run_results(type).count
      end

      def test_run_result_messages
        @test_run_results.map(&:message)
      end

      def last_test_run_result
        @test_run_results.last
      end
    end

  end

end
