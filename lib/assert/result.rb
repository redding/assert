module Assert; end
module Assert::Result

  class Base

    attr_reader :test_name, :message, :backtrace, :abbrev

    def initialize(test_name, message, backtrace)
      raise ArgumentError unless backtrace.kind_of?(::Array)
      @backtrace = backtrace
      @test_name = test_name
      @message = message
    end

    [:pass?, :fail?, :error?, :skip?].each do |meth|
      define_method("#{meth}") { false }
    end

    def abbrev; nil; end
    def to_sym; nil; end

    def to_s
      [self.test_name, self.message, self.trace].compact.join("\n")
    end

    def trace
      # TODO: filter?
      # TODO: only show first item (should be the test line where the result happened)
      self.backtrace.join("\n")
    end

  end

  class Pass < Base
    def pass?; true; end
    def abbrev; '.'; end
    def to_sym; :passed; end

    def to_s
      "PASS: #{super}"
    end
  end

  class Fail < Base
    def fail?; true; end
    def abbrev; 'F'; end
    def to_sym; :failed; end

    def to_s
      "FAIL: #{super}"
    end
  end

  # TODO: Ignored result??

  # Error and Skip results are built from exceptions being raised
  class FromException < Base
    def initialize(test_name, exception)
      super(test_name, exception.message, exception.backtrace || [])
    end
  end

  # raised by the 'skip' context helper to break test execution
  class TestSkipped < RuntimeError; end

  class Skip < FromException
    def skip?; true; end
    def abbrev; 'S'; end
    def to_sym; :skipped; end

    def to_s
      "SKIP: #{super}"
    end
  end

  class Error < FromException

    def error?; true; end
    def abbrev; 'E'; end
    def to_sym; :errored; end

    def to_s
      "ERROR: #{super}"
    end

    # override of the base, always show the full unfiltered backtrace for errors
    def trace
      self.backtrace.join("\n")
    end
  end

end
