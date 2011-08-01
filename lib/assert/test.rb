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

    def result_count
      @results.size
    end

  end
end
