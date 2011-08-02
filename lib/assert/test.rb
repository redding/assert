module Assert
  class Test

    # a Test is some code/method to run in the scope of a Context.  After a
    # a test runs, it should have some assertions which are its results.

    attr_reader :name, :code
    attr_accessor :results

    def initialize(name, code)
      @name = name
      @code = code
      @results = []
    end

    def result_count(type=nil)
      case type
      when :pass
        @results.select{|r| r.kind_of?(Result::Pass)}.size
      when :fail
        @results.select{|r| r.kind_of?(Result::Fail)}.size
      when :skip
        @results.select{|r| r.kind_of?(Result::Skip)}.size
      when :error
        @results.select{|r| r.kind_of?(Result::Error)}.size
      else
        @results.size
      end
    end
    alias_method :assert_count, :result_count

  end
end
