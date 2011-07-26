module Assert; end
module Assert::Result

  class Base
    attr_reader :message

    def initialize(message)
      @message = message
    end

    [:pass?, :fail?, :error?, :skip?].each do |meth|
      define_method("#{meth}") { false }
    end
  end

  class Pass < Base
    def pass?
      true
    end
  end

  class Fail < Base
    def fail?
      true
    end
  end

  class Error < Base
    def error?
      true
    end
  end

  class Skip < Base
    def skip?
      true
    end
  end

end