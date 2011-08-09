module Assert::View

  class Base

    def initialize(suite, output_io)
      @suite = suite
      @out = output_io
    end

    # override this to define how a view calls the runner and renders its results
    def render(*args, &runner)
      raise NotImplementedError
    end

    def print_result(result)
      io_print(result.abbrev)
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
        self.send(msg)
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
