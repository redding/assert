require 'assert'

module Assert

  module Utils

    # show objects in a human-readable manner.  Either inspects or pretty-prints
    # them depending on settings.

    def self.show(obj)
      out = Assert.config.pp_objects ? Assert.config.pp_proc.call(obj) : obj.inspect
      out = out.encode(Encoding.default_external) if defined?(Encoding)
      out
    end

    # Get a proc that uses stdlib `PP.pp` to pretty print objects

    def self.stdlib_pp_proc(width = nil)
      require 'pp'
      Proc.new{ |obj| "\n#{PP.pp(obj, '', width || 79).strip}\n" }
    end

  end

  # alias for brevity
  U = Utils

end
