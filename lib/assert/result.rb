module Assert; end
module Assert::Result

  class Base < RuntimeError
    [:pass?, :fail?, :error?, :skip?].each do |meth|
      define_method("#{meth}") { false }
    end

    def abbrev; nil; end
    def to_sym; nil; end
  end

  class Pass < Base
    def pass?; true; end
    def abbrev; '.'; end
    def to_sym; :passed; end
  end

  class Fail < Base
    def fail?; true; end
    def abbrev; 'F'; end
    def to_sym; :failed; end
  end

  class Error < Base
    def error?; true; end
    def abbrev; 'E'; end
    def to_sym; :errored; end
  end

  class Skip < Base
    def skip?; true; end
    def abbrev; 'S'; end
    def to_sym; :skipped; end
  end

end
