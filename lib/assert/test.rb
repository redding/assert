require 'assert/result_set'

module Assert
  class Test

    # a Test is some code/method to run in the scope of a Context.  After a
    # a test runs, it should have some assertions which are its results.

    attr_reader :name, :code, :context
    attr_accessor :results

    def initialize(name, code, context)
      @context = context
      @name = name_from_context(name)
      @code = code
      @results = ResultSet.new
    end

    def run(view=nil)
      @results.view = view
      capture_results do
        run_scope = @context.new(self)
        run_setup(run_scope)
        if @code.kind_of?(::Proc)
          run_scope.instance_eval(&@code)
        elsif run_scope.respond_to?(@code.to_s)
          run_scope.send(@code.to_s)
        end
        run_teardown(run_scope)
      end
      @results.view = nil
      @results
    end

    def run_setup(scope)
      @context._assert_setups.each do |setup|
        scope.instance_eval(&setup)
      end
    end

    def run_teardown(scope)
      @context._assert_teardowns.each do |teardown|
        scope.instance_eval(&teardown)
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

    protected

    def name_from_context(name)
      (@context._assert_descs + [ name ]).join(" ")
    end

    def capture_results(view=nil, &block)
      begin
        block.call if block
      rescue Result::Base => err
        @results << err
      rescue Exception => exp
        err = Result::Error.new(exp)
        @results << err
      end
    end

  end
end
