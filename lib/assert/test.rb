require 'stringio'
require 'assert/file_line'
require 'assert/result'

module Assert

  class Test

    # a Test is some code/method to run in the scope of a Context.  After a
    # a test runs, it should have some assertions which are its results.

    attr_reader :context_info, :config, :code, :results, :data

    def initialize(name, suite_ci, config, opts = nil, &block)
      o = opts || {}
      @context_info = suite_ci
      @config       = config
      @code         = o[:code] || block || Proc.new{}
      @results      = []
      @data         = Data.new

      @data.name, @data.file_line = name_file_line_from_context(@context_info, name)
    end

    def name;         self.data.name;         end
    def file_line;    self.data.file_line;    end
    def output;       self.data.output;       end
    def output=(val); self.data.output = val; end
    def run_time;     self.data.run_time;     end
    def result_rate;  self.data.result_rate;  end

    def result_count(type = nil)
      self.data.result_count(type)
    end

    def context_class; self.context_info.klass; end
    def file;          self.file_line.file;     end
    def line_number;   self.file_line.line;     end

    def run(&result_callback)
      result_callback ||= proc{ |result| } # do nothing by default
      scope = self.context_class.new(self, self.config, result_callback)
      start_time = Time.now
      capture_output do
        self.context_class.send('run_arounds', scope) do
          run_test_main(scope, result_callback)
        end
      end
      @data.run_time = Time.now - start_time

      @results
    end

    def capture_result(result, callback)
      self.results << result
      self.data.capture_result(result)
      callback.call(result)
    end

    Assert::Result.types.each do |name, klass|
      define_method "#{name}_results" do
        @results.select{|r| r.kind_of?(klass) }
      end
    end

    def <=>(other_test)
      self.name <=> other_test.name
    end

    def inspect
      attributes_string = ([ :name, :context_info, :results ].collect do |attr|
        "@#{attr}=#{self.send(attr).inspect}"
      end).join(" ")
      "#<#{self.class}:#{'0x0%x' % (object_id << 1)} #{attributes_string}>"
    end

    private

    def run_test_main(scope, result_callback)
      begin
        run_test_setup(scope)
        run_test_code(scope)
      rescue Result::TestFailure => err
        capture_result(Result::Fail.new(self, err), result_callback)
      rescue Result::TestSkipped => err
        capture_result(Result::Skip.new(self, err), result_callback)
      rescue SignalException => err
        raise(err)
      rescue Exception => err
        capture_result(Result::Error.new(self, err), result_callback)
      ensure
        begin
          run_test_teardown(scope)
        rescue Result::TestFailure => err
          capture_result(Result::Fail.new(self, err), result_callback)
        rescue Result::TestSkipped => err
          capture_result(Result::Skip.new(self, err), result_callback)
        rescue SignalException => err
          raise(err)
        rescue Exception => err
          capture_result(Result::Error.new(self, err), result_callback)
        end
      end
    end

    def run_test_setup(scope)
      # run any assert style 'setup do' setups
      self.context_class.send('run_setups', scope)

      # run any test/unit style 'def setup' setups
      scope.setup if scope.respond_to?(:setup)
    end

    def run_test_code(scope)
      if @code.kind_of?(::Proc)
        scope.instance_eval(&@code)
      elsif scope.respond_to?(@code.to_s)
        scope.send(@code.to_s)
      end
    end

    def run_test_teardown(scope)
      # run any assert style 'teardown do' teardowns
      self.context_class.send('run_teardowns', scope)

      # run any test/unit style 'def teardown' teardowns
      scope.teardown if scope.respond_to?(:teardown)
    end

    def capture_output(&block)
      if self.config.capture_output == true
        orig_stdout = $stdout.clone
        $stdout = capture_io
        block.call
        $stdout = orig_stdout
      else
        block.call
      end
    end

    def capture_io
      StringIO.new(@data.output, "a+")
    end

    def name_file_line_from_context(context_info, name)
      [ [ context_info.klass.description,
          name
        ].compact.reject(&:empty?).join(" "),
        FileLine.parse(context_info.called_from)
      ]
    end

    class Data

      def self.result_count_meth(type)
        "#{type}_result_count".to_sym
      end

      attr_accessor :name, :file_line, :output, :run_time, :total_result_count
      attr_accessor *Assert::Result.types.keys.map{ |type| result_count_meth(type) }

      def initialize(data = nil)
        data ||= {}

        @name      = data[:name]
        @file_line = data[:file_line]
        @output    = data[:output] || ''
        @run_time  = data[:run_time] || 0

        @total_result_count = data[:total_result_count] || 0
        Assert::Result.types.keys.each do |type|
          n = result_count_meth(type)
          instance_variable_set("@#{n}", data[n] || 0)
        end
      end

      def result_rate
        get_rate(self.result_count, self.run_time)
      end

      def result_count(type = nil)
        if Assert::Result.types.keys.include?(type)
          self.send(result_count_meth(type))
        else
          self.total_result_count
        end
      end

      def capture_result(result)
        self.total_result_count += 1
        n = result_count_meth(result.to_sym)
        self.send("#{n}=", self.send(n) + 1)
      end

      private

      def result_count_meth(type)
        self.class.result_count_meth(type)
      end

      def get_rate(count, time)
        time == 0 ? 0.0 : (count.to_f / time.to_f)
      end

    end

  end

end
