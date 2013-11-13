require 'assert'

module Assert

  module Utils

    def self.pp(input)
      output = Assert.config.pp_processor.to_proc.call(input)
      output = output.encode(Encoding.default_external) if defined?(Encoding)
      output
    end

  end

  # alias for brevity
  U = Utils

end
