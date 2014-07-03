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
      @object = object
      @metaclass = class << @object; self; end
      @method_name = method_name.to_s
      @name = "__assert_stub__#{@object.object_id}_#{@method_name}"
      @ivar_name = "@__assert_stub_#{@object.object_id}_" \
                   "#{@method_name.to_sym.object_id}"

      setup

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
      raise StubArityError, "artiy mismatch" unless arity_matches?(args)
      @lookup[args].call(*args, &block)
    rescue NotStubbedError => exception
      @lookup.rehash
      @lookup[args].call(*args, &block)
    end

    def with(*args, &block)
      raise StubArityError, "artiy mismatch" unless arity_matches?(args)
      @lookup[args] = block
    end

    def do=(block)
      @do = block || @do
    end

    def teardown
      @metaclass.send(:undef_method, @method_name)
      @object.send(:remove_instance_variable, @ivar_name)
      @metaclass.send(:alias_method, @method_name, @name)
      @metaclass.send(:undef_method, @name)
    end

    protected

    def setup
      unless @object.respond_to?(@method_name)
        raise StubError, "#{@object.inspect} does not respond to `#{@method_name}`"
      end
      is_constant = @object.kind_of?(Module)
      local_object_methods = @object.methods(false).map(&:to_s)
      all_object_methods = @object.methods.map(&:to_s)
      if (is_constant && !local_object_methods.include?(@method_name)) ||
         (!is_constant && !all_object_methods.include?(@method_name))
        @metaclass.class_eval <<-method
          def #{@method_name}(*args, &block)
            super(*args, &block)
          end
        method
      end

      if !local_object_methods.include?(@name) # already stubbed
        @metaclass.send(:alias_method, @name, @method_name)
      end
      @method = @object.method(@name)

      @object.instance_variable_set(@ivar_name, self)
      @metaclass.class_eval <<-stub_method
        def #{@method_name}(*args, &block)
          #{@ivar_name}.call(*args, &block)
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

  end

end
