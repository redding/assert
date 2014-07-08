module Assert

  def self.stubs
    @stubs ||= {}
  end

  def self.stub(*args, &block)
    (self.stubs[Assert::Stub.key(*args)] ||= Assert::Stub.new(*args)).tap do |s|
      s.do = block
    end
  end

  def self.unstub(*args)
    (self.stubs.delete(Assert::Stub.key(*args)) || Assert::Stub::NullStub.new).teardown
  end

  def self.unstub!
    self.stubs.keys.each{ |key| self.stubs.delete(key).teardown }
  end

  StubError = Class.new(ArgumentError)
  NotStubbedError = Class.new(StubError)
  StubArityError = Class.new(StubError)

  class Stub

    NullStub = Class.new do
      def teardown; end # no-op
    end

    def self.key(object, method_name)
      "--#{object.object_id}--#{method_name}--"
    end

    attr_reader :method_name, :name, :ivar_name, :do

    def initialize(object, method_name, &block)
      @metaclass = class << object; self; end
      @method_name = method_name.to_s
      @name = "__assert_stub__#{object.object_id}_#{@method_name}"
      @ivar_name = "@__assert_stub_#{object.object_id}_" \
                   "#{@method_name.to_sym.object_id}"

      setup(object)

      @do = block || Proc.new do |*args, &block|
        err_msg = "#{inspect_call(args)} not stubbed."
        inspect_lookup_stubs.tap do |stubs|
          err_msg += "\nStubs:\n#{stubs}" if !stubs.empty?
        end
        raise NotStubbedError, err_msg
      end
      @lookup = Hash.new{ |hash, key| self.do }
    end

    def call(*args, &block)
      unless arity_matches?(args)
        message = "arity mismatch on `#{@method_name}`: " \
                  "expected #{number_of_args(@method.arity)}, " \
                  "called with #{args.size}"
        raise StubArityError, message
      end
      @lookup[args].call(*args, &block)
    rescue NotStubbedError => exception
      @lookup.rehash
      @lookup[args].call(*args, &block)
    end

    def with(*args, &block)
      unless arity_matches?(args)
        message = "arity mismatch on `#{@method_name}`: " \
                  "expected #{number_of_args(@method.arity)}, " \
                  "stubbed with #{args.size}"
        raise StubArityError, message
      end
      @lookup[args] = block
    end

    def do=(block)
      @do = block || @do
    end

    def teardown
      @metaclass.send(:undef_method, @method_name)
      Assert.send(:remove_instance_variable, @ivar_name)
      @metaclass.send(:alias_method, @method_name, @name)
      @metaclass.send(:undef_method, @name)
    end

    def inspect
      "#<#{self.class}:#{'0x0%x' % (object_id << 1)}" \
      " @method_name=#{@method_name.inspect}" \
      ">"
    end

    protected

    def setup(object)
      unless object.respond_to?(@method_name)
        raise StubError, "#{object.inspect} does not respond to `#{@method_name}`"
      end
      is_constant = object.kind_of?(Module)
      local_object_methods = object.methods(false).map(&:to_s)
      all_object_methods = object.methods.map(&:to_s)
      if (is_constant && !local_object_methods.include?(@method_name)) ||
         (!is_constant && !all_object_methods.include?(@method_name))
        params_list = ParameterList.new(object, @method_name)
        @metaclass.class_eval <<-method
          def #{@method_name}(#{params_list}); super; end
        method
      end

      if !local_object_methods.include?(@name) # already stubbed
        @metaclass.send(:alias_method, @name, @method_name)
      end
      @method = object.method(@name)

      Assert.instance_variable_set(@ivar_name, self)
      @metaclass.class_eval <<-stub_method
        def #{@method_name}(*args, &block)
          Assert.instance_variable_get("#{@ivar_name}").call(*args, &block)
        end
      stub_method
    end

    private

    def arity_matches?(args)
      return true if @method.arity == args.size # mandatory args
      return true if @method.arity < 0 && args.size >= (@method.arity+1).abs # variable args
      return false
    end

    def inspect_lookup_stubs
      @lookup.keys.map{ |args| "    - #{inspect_call(args)}" }.join("\n")
    end

    def inspect_call(args)
      "`#{@method_name}(#{args.map(&:inspect).join(',')})`"
    end

    def number_of_args(arity)
      if arity < 0
        "at least #{(arity + 1).abs}"
      else
        arity
      end
    end

    module ParameterList
      LETTERS = ('a'..'z').to_a.freeze

      def self.new(object, method_name)
        arity = get_arity(object, method_name)
        params = build_params_from_arity(arity)
        params << '*args' if arity < 0
        params << '&block'
        params.join(', ')
      end

      private

      def self.get_arity(object, method_name)
        object.method(method_name).arity
      rescue NameError
        -1
      end

      def self.build_params_from_arity(arity)
        number = arity < 0 ? (arity + 1).abs : arity
        (0..(number - 1)).map{ |param_index| get_param_name(param_index) }
      end

      def self.get_param_name(param_index)
        param_index += LETTERS.size # avoid getting 0 for the number of letters
        number_of_letters, letter_index = param_index.divmod(LETTERS.size)
        LETTERS[letter_index] * number_of_letters
      end
    end

  end

end
