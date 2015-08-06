require 'stringio'
require 'assert/file_line'
require 'assert/result'

module Assert

  class Test

    # a Test is some code/method to run in the scope of a Context that may
    # produce results

    def self.result_count_meth(type)
      "#{type}_result_count".to_sym
    end

    def self.name_file_line_context_data(ci, name)
      { :name      => ci.test_name(name),
        :file_line => ci.called_from
      }
    end

    def self.for_block(name, context_info, config, &block)
      self.new(self.name_file_line_context_data(context_info, name).merge({
        :context_info => context_info,
        :config       => config,
        :code         => block
      }))
    end

    def self.for_method(method_name, context_info, config)
      self.new(self.name_file_line_context_data(context_info, method_name).merge({
        :context_info => context_info,
        :config       => config,
        :code         => proc{ self.send(method_name) }
      }))
    end

    attr_reader :results
    attr_writer :total_result_count

    def initialize(build_data = nil)
      @build_data, @results = build_data || {}, []
    end

    def file_line; @file_line ||= FileLine.parse((@build_data[:file_line] || '').to_s); end
    def name;      @name      ||= (@build_data[:name]                     || '');       end
    def output;    @output    ||= (@build_data[:output]                   || '');       end
    def run_time;  @run_time  ||= (@build_data[:run_time]                 || 0);        end

    def total_result_count
      @total_result_count ||= (@build_data[:total_result_count] || 0)
    end

    Assert::Result.types.keys.each do |type|
      n = result_count_meth(type)
      define_method(n) do
        instance_variable_get("@#{n}") || instance_variable_set("@#{n}", @build_data[n] || 0)
      end
    end

    def context_info; @context_info ||= @build_data[:context_info]; end
    def config;       @config       ||= @build_data[:config];       end
    def code;         @code         ||= @build_data[:code];         end

    def data
      { :file_line => self.file_line.to_s,
        :name      => self.name.to_s,
        :output    => self.output.to_s,
        :run_time  => self.run_time
      }.merge(result_count_data(:total_result_count => self.total_result_count))
    end

    def context_class; self.context_info.klass; end
    def file;          self.file_line.file;     end
    def line_number;   self.file_line.line;     end

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

    def capture_result(result, callback)
      self.results << result
      self.total_result_count += 1
      n = result_count_meth(result.to_sym)
      instance_variable_set("@#{n}", (instance_variable_get("@#{n}") || 0) + 1)
      callback.call(result)
    end

    def run(&result_callback)
      result_callback ||= proc{ |result| } # do nothing by default
      scope = self.context_class.new(self, self.config, result_callback)
      start_time = Time.now
      capture_output do
        self.context_class.send('run_arounds', scope) do # TODO: why `send`?
          run_test(scope, result_callback)
        end
      end
      @run_time = Time.now - start_time
      @results
    end

    Assert::Result.types.each do |name, klass|
      define_method "#{name}_results" do
        self.results.select{|r| r.kind_of?(klass) }
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

    def run_test(scope, result_callback)
      begin
        # run any assert style 'setup do' setups
        self.context_class.send('run_setups', scope) # TODO: why `send`?
        # run any test/unit style 'def setup' setups
        scope.setup if scope.respond_to?(:setup)
        # run the code block
        scope.instance_eval(&(self.code || proc{}))
      rescue Result::TestFailure => err
        capture_result(Result::Fail.for_test(self, err), result_callback)
      rescue Result::TestSkipped => err
        capture_result(Result::Skip.for_test(self, err), result_callback)
      rescue SignalException => err
        raise(err)
      rescue Exception => err
        capture_result(Result::Error.for_test(self, err), result_callback)
      ensure
        begin
          # run any assert style 'teardown do' teardowns
          self.context_class.send('run_teardowns', scope) # TODO: why `send`?
          # run any test/unit style 'def teardown' teardowns
          scope.teardown if scope.respond_to?(:teardown)
        rescue Result::TestFailure => err
          capture_result(Result::Fail.for_test(self, err), result_callback)
        rescue Result::TestSkipped => err
          capture_result(Result::Skip.for_test(self, err), result_callback)
        rescue SignalException => err
          raise(err)
        rescue Exception => err
          capture_result(Result::Error.for_test(self, err), result_callback)
        end
      end
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
      StringIO.new(self.output, "a+")
    end

    def result_count_data(seed)
      Assert::Result.types.keys.inject(seed) do |d, t|
        d[result_count_meth(t)] = self.send(result_count_meth(t))
        d
      end
    end

    def result_count_meth(type)
      self.class.result_count_meth(type)
    end

    def get_rate(count, time)
      time == 0 ? 0.0 : (count.to_f / time.to_f)
    end

  end

end
