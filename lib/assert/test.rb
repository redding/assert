require 'stringio'
require 'assert/result'

module Assert
  class Test

    # a Test is some code/method to run in the scope of a Context.  After a
    # a test runs, it should have some assertions which are its results.

    attr_reader :name, :code, :context_info
    attr_accessor :results, :output

    def initialize(name, suite_context_info, code = nil, &block)
      @context_info = suite_context_info
      @name = name_from_context(name)
      @code = (code || block)
      @results = Result::Set.new
      @output = ""
    end

    def context_class
      self.context_info.klass
    end

    def run(&result_callback)
      # setup the a new test run
      @results = Result::Set.new(result_callback)
      run_scope = self.context_class.new(self)

      # run the test, capturing its output
      begin
        run_test_setup(run_scope)
        run_test_code(run_scope)
      rescue Result::TestFailure => err
        @results << Result::Fail.new(self, err)
      rescue Result::TestSkipped => err
        @results << Result::Skip.new(self, err)
      rescue Exception => err
        @results << Result::Error.new(self, err)
      ensure
        begin
          run_test_teardown(run_scope)
        rescue Result::TestSkipped => err
          @results << Result::Skip.new(self, err)
        rescue Exception => teardown_err
          @results << Result::Error.new(self, teardown_err)
        end
      end
      # return the results of the test run
      @results
    end

    Assert::Result.types.each do |name, klass|
      define_method "#{name}_results" do
        @results.select{|r| r.kind_of?(klass) }
      end
    end

    def result_count(type=nil)
      if Assert::Result.types.include?(type)
        self.send("#{type}_results").size
      else
        @results.size
      end
    end

    def <=>(other_test)
      self.name <=> other_test.name
    end

    def inspect
      attributes_string = ([ :name, :context_info, :results ].collect do |attr|
        "@#{attr}=#{self.send(attr).inspect}"
      end).join(" ")
      "#<#{self.class} #{attributes_string}>"
    end

    protected

    def run_test_setup(scope)
      capture_output do
        # run any assert style 'setup do' setups
        self.context_class.setup(scope)

        # run any classic test/unit style 'def setup' setups
        scope.setup if scope.respond_to?(:setup)
      end
    end

    def run_test_code(scope)
      capture_output do
        if @code.kind_of?(::Proc)
          scope.instance_eval(&@code)
        elsif scope.respond_to?(@code.to_s)
          scope.send(@code.to_s)
        end
      end
    end

    def run_test_teardown(scope)
      capture_output do
        # run any classic test/unit style 'def teardown' teardowns
        scope.teardown if scope.respond_to?(:teardown)

        # run any assert style 'teardown do' teardowns
        self.context_class.teardown(scope)
      end
    end

    def capture_output(&block)
      if Assert.config.capture_output == true
        orig_stdout = $stdout.clone
        $stdout = capture_io
        block.call
        $stdout = orig_stdout
      else
        block.call
      end
    end

    def capture_io
      StringIO.new(@output, "a+")
    end

    def name_from_context(name)
      [ self.context_class.description,
        name
      ].compact.reject{|p| p.empty?}.join(" ")
    end

  end
end
