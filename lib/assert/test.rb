require 'stringio'
require 'assert/file_line'
require 'assert/result'

module Assert

  class Test

    # a Test is some code/method to run in the scope of a Context that may
    # produce results

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

    def initialize(build_data = nil)
      @build_data      = build_data || {}
      @result_callback = nil
    end

    def file_line
      @file_line ||= FileLine.parse((@build_data[:file_line] || '').to_s)
    end

    def file_name; self.file_line.file;      end
    def line_num;  self.file_line.line.to_i; end

    def name
      @name ||= (@build_data[:name] || '')
    end

    def output
      @output ||= (@build_data[:output] || '')
    end

    def run_time
      @run_time ||= (@build_data[:run_time] || 0)
    end

    def context_info
      @context_info ||= @build_data[:context_info]
    end

    def context_class
      self.context_info.klass
    end

    def config
      @config ||= @build_data[:config]
    end

    def code
      @code ||= @build_data[:code]
    end

    def run(&result_callback)
      @result_callback = result_callback || proc{ |result| } # noop by default
      scope = self.context_class.new(self, self.config, @result_callback)
      start_time = Time.now
      capture_output do
        self.context_class.run_arounds(scope){ run_test(scope) }
      end
      @result_callback = nil
      @run_time = Time.now - start_time
    end

    def <=>(other_test)
      self.name <=> other_test.name
    end

    def inspect
      attributes_string = ([:name, :context_info].collect do |attr|
        "@#{attr}=#{self.send(attr).inspect}"
      end).join(" ")
      "#<#{self.class}:#{'0x0%x' % (object_id << 1)} #{attributes_string}>"
    end

    private

    def run_test(scope)
      begin
        # run any assert style 'setup do' setups
        self.context_class.run_setups(scope)
        # run any test/unit style 'def setup' setups
        scope.setup if scope.respond_to?(:setup)
        # run the code block
        scope.instance_eval(&(self.code || proc{}))
      rescue Result::TestFailure => err
        capture_result(Result::Fail, err)
      rescue Result::TestSkipped => err
        capture_result(Result::Skip, err)
      rescue SignalException => err
        raise(err)
      rescue Exception => err
        capture_result(Result::Error, err)
      ensure
        begin
          # run any assert style 'teardown do' teardowns
          self.context_class.run_teardowns(scope)
          # run any test/unit style 'def teardown' teardowns
          scope.teardown if scope.respond_to?(:teardown)
        rescue Result::TestFailure => err
          capture_result(Result::Fail, err)
        rescue Result::TestSkipped => err
          capture_result(Result::Skip, err)
        rescue SignalException => err
          raise(err)
        rescue Exception => err
          capture_result(Result::Error, err)
        end
      end
    end

    def capture_result(result_klass, err)
      @result_callback.call(result_klass.for_test(self, err))
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

  end

end
