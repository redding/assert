module Assert
  class Test

    # a Test is some code/method to run in the scope of a Context.  After a
    # a test runs, it should have some assertions which are its results.

    attr_reader :name, :code, :context
    attr_accessor :results

    def initialize(name, code, context)
      @name = name
      @code = code
      @context = context
      @results = []
    end

    def run
      begin
        run_scope = @context.new(self)
        # TODO: setups
        if @code.kind_of?(::Proc)
          run_scope.instance_eval(&@code)
        elsif run_scope.respond_to?(@code.to_s)
          run_scope.send(@code.to_s)
        end
        # TODO: teardowns
      rescue Result::Base => err
        @results << err
      rescue Exception => err
        @results << Result::Error.new(err)
      end
    end

    # capture a pass or fail result from a given block and return it
    # pass and fail results are captured here to not break test execution.
    # skip or error results never get handled here b/c they break
    # execution before this code runs.
    def assertion_result
      begin
        yield if block_given?
      rescue Result::Pass => err
        @results << err
        err
      rescue Result::Fail => err
        @results << err
        err
      else
        raise RuntimeError, "no pass or fail result captured"
      end
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

    def <=>(other_test)
      self.name <=> other_test.name
    end

  end
end
