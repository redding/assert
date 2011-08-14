require 'assert/options'

module Assert::View

  class Base
    include Assert::Options

    attr_reader :suite

    def initialize(suite, output_io)
      @suite = suite
      @out = output_io
    end

    # override this to define how a view calls the runner and renders its results
    def render(*args, &runner)
    end

    def print_runtime_result(result)
      sym = result.to_sym
      if self.respond_to?(:options)
        io_print(self.options.send("#{sym}_abbrev"))
      end
    end

    protected

    def io_puts(msg, opts={})
      @out.puts(io_msg(msg, opts={}))
    end

    def io_print(msg, opts={})
      @out.print(io_msg(msg, opts={}))
    end

    def io_msg(msg, opts={})
      if msg.kind_of?(::Symbol) && self.respond_to?(msg)
        self.send(msg).to_s
      else
        msg.to_s
      end
    end

    def run_time(format='%.6f')
      format % @suite.run_time
    end

    def count(type)
      @suite.count(type)
    end

  end

end
