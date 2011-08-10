module Assert; end
module Assert::Result

  class Base; end
  class Pass < Base; end
  class Fail < Base; end
  class Ignore < Base; end
  class FromException < Base; end
  class Error < FromException; end
  class Skip < FromException; end

  class << self
    def types
      { :pass => Pass,
        :fail => Fail,
        :ignore => Ignore,
        :skip => Skip,
        :error => Error
      }
    end
  end

  class Backtrace < ::Array
    # ripped from minitest...

    file = File.expand_path __FILE__
           # if RUBY_VERSION =~ /^1\.9/ then  # bt's expanded, but __FILE__ isn't :(
           #    File.expand_path __FILE__
           # elsif  __FILE__ =~ /^[^\.]/ then # assume both relative
           #   require 'pathname'
           #   pwd = Pathname.new Dir.pwd
           #   pn = Pathname.new File.expand_path(__FILE__)
           #   relpath = pn.relative_path_from(pwd) rescue pn
           #   pn = File.join ".", relpath unless pn.relative?
           #   pn.to_s
           # else                             # assume both are expanded
           #   __FILE__
           # end

    # './lib' in project dir, or '/usr/local/blahblah' if installed
    ASSERT_DIR = File.dirname(File.dirname(file))

    def initialize(value=nil)
      super(value || ["No backtrace"])
    end

    def to_s
      self.join("\n")
    end

    def filtered
      new_bt = []

      self.each do |line|
        break if line.rindex ASSERT_DIR, 0
        new_bt << line
      end

      new_bt = self.reject { |line| line.rindex ASSERT_DIR, 0 } if new_bt.empty?
      new_bt = self.dup if new_bt.empty?

      self.class.new(new_bt)
    end
  end


  # Result classes...

  class Base

    attr_reader :test_name, :message, :backtrace, :abbrev

    def initialize(test_name, message, backtrace=nil)
      @backtrace = Backtrace.new(backtrace)
      @test_name = test_name
      @message = message && !message.empty? ? message : nil
    end

    Assert::Result.types.keys.each do |meth|
      define_method("#{meth}?") { false }
    end

    def abbrev; nil; end
    def to_sym; nil; end

    def to_s
      [self.test_name, self.message, self.trace].compact.join("\n")
    end

    def trace
      self.backtrace.filtered.first.to_s
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

  class Ignore < Base
    def ignore?; true; end
    def abbrev; 'I'; end
    def to_sym; :ignored; end

    def to_s
      "IGNORE: #{super}"
    end
  end

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
      self.backtrace.to_s
    end
  end

end
