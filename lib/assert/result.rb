module Assert; end
module Assert::Result

  class Base

    attr_reader :message

    def initialize(message)
      @message = message
    end

    [:pass?, :fail?, :error?, :skip?].each do |meth|
      define_method("#{meth}") { raise NotImplementedError }
    end

  end

end