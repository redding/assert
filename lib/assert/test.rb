require 'assert/result'
require 'assert/result_set'
require 'assert/options'

require 'stringio'

module Assert
  class Test
    include Assert::Options
    options do
      default_capture_output false
      default_halt_on_fail   true
    end

    def self.halt_on_fail?
      ENV['halt_on_fail'] == 'true' || self.options.halt_on_fail
    end

    # a Test is some code/method to run in the scope of a Context.  After a
    # a test runs, it should have some assertions which are its results.

    attr_reader :name, :code, :context_info
    attr_accessor :results, :output

    def initialize(name, suite_context_info, code = nil, &block)
      @context_info = suite_context_info
      @name = name_from_context(name)
      @code = (code || block)
      @results = ResultSet.new
      @output = ""
    end

    def context_class
      self.context_info.klass
    end

    def run(view=nil)
      @results.view = view
      run_scope = self.context_class.new(self)
      capture_output(StringIO.new(@output, "w+")) do
        begin
          # run any assert style 'setup do' setups
          self.context_class.setup(run_scope)
          # run any classic test/unit style 'def setup' setups
          if run_scope.respond_to?(:setup)
            run_scope.setup
          end

          # run the actual test code
          if @code.kind_of?(::Proc)
            run_scope.instance_eval(&@code)
          elsif run_scope.respond_to?(@code.to_s)
            run_scope.send(@code.to_s)
          end
        rescue Result::TestFailure => err
          @results << Result::Fail.new(self, err)
        rescue Result::TestSkipped => err
          @results << Result::Skip.new(self, err)
        rescue Exception => err
          @results << Result::Error.new(self, err)
        ensure
          begin
            # run any classic test/unit style 'def teardown' teardowns
            if run_scope.respond_to?(:teardown)
              run_scope.teardown
            end
            # run any assert style 'teardown do' teardowns
            self.context_class.teardown(run_scope)
          rescue Exception => teardown_err
            @results << Result::Error.new(self, teardown_err)
          end
        end
      end
      @results.view = nil
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

    def capture_output(io, &block)
      if self.class.options.capture_output && io
        orig_stdout = $stdout.clone
        $stdout = io
        block.call
        $stdout = orig_stdout
      else
        block.call
      end
    end

    def name_from_context(name)
      [ self.context_class.description,
        name
      ].compact.reject{|p| p.empty?}.join(" ")
    end

  end
end
