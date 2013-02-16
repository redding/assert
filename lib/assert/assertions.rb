module Assert
  module Assertions

    def assert_block(desc=nil)
      msg ||= "Expected block to return a true value."
      assert(yield, desc, msg)
    end

    def assert_not_block(desc=nil)
      msg ||= "Expected block to return a false value."
      assert(!yield, desc, msg)
    end
    alias_method :refute_block, :assert_not_block

    def assert_empty(collection, desc=nil)
      msg = "Expected #{collection.inspect} to be empty."
      assert(collection.empty?, desc, msg)
    end

    def assert_not_empty(collection, desc=nil)
      msg = "Expected #{collection.inspect} to not be empty."
      assert(!collection.empty?, desc, msg)
    end
    alias_method :refute_empty, :assert_not_empty

    def assert_equal(expected, actual, desc=nil)
      msg = "Expected #{expected.inspect}, not #{actual.inspect}."
      assert(actual == expected, desc, msg)
    end

    def assert_not_equal(expected, actual, desc=nil)
      msg = "#{actual.inspect} not expected to equal #{expected.inspect}."
      assert(actual != expected, desc, msg)
    end
    alias_method :refute_equal, :assert_not_equal

    def assert_file_exists(file_path, desc=nil)
      msg = "Expected #{file_path.inspect} to exist."
      assert(File.exists?(File.expand_path(file_path)), desc, msg)
    end

    def assert_not_file_exists(file_path, desc=nil)
      msg = "Expected #{file_path.inspect} to not exist."
      assert(!File.exists?(File.expand_path(file_path)), desc, msg)
    end
    alias_method :refute_file_exists, :assert_not_file_exists

    def assert_includes(object, collection, desc=nil)
      msg = "Expected #{collection.inspect} to include #{object.inspect}."
      assert(collection.include?(object), desc, msg)
    end
    alias_method :assert_included, :assert_includes

    def assert_not_includes(object, collection, desc=nil)
      msg = "Expected #{collection.inspect} to not include #{object.inspect}."
      assert(!collection.include?(object), desc, msg)
    end
    alias_method :assert_not_included, :assert_not_includes
    alias_method :refute_includes, :assert_not_includes
    alias_method :refute_included, :assert_not_includes

    def assert_instance_of(klass, instance, desc=nil)
      msg = "Expected #{instance.inspect} (#{instance.class}) to"\
            " be an instance of #{klass}."
      assert(instance.instance_of?(klass), desc, msg)
    end

    def assert_not_instance_of(klass, instance, desc=nil)
      msg = "#{instance.inspect} not expected to be an instance of #{klass}."
      assert(!instance.instance_of?(klass), desc, msg)
    end
    alias_method :refute_instance_of, :assert_not_instance_of

    def assert_kind_of(klass, instance, desc=nil)
      msg = "Expected #{instance.inspect} (#{instance.class}) to"\
            " be a kind of #{klass}."
      assert(instance.kind_of?(klass), desc, msg)
    end

    def assert_not_kind_of(klass, instance, desc=nil)
      msg = "#{instance.inspect} not expected to be a kind of #{klass}."
      assert(!instance.kind_of?(klass), desc, msg)
    end
    alias_method :refute_kind_of, :assert_not_kind_of

    def assert_match(expected, actual, desc=nil)
      msg = "Expected #{actual.inspect} to match #{expected.inspect}."
      expected = /#{Regexp.escape(expected)}/ if String === expected && String === actual
      assert(actual =~ expected, desc, msg)
    end

    def assert_not_match(expected, actual, desc=nil)
      msg = "#{actual.inspect} not expected to match #{expected.inspect}."
      expected = /#{Regexp.escape(expected)}/ if String === expected && String === actual
      assert(actual !~ expected, desc, msg)
    end
    alias_method :refute_match, :assert_not_match
    alias_method :assert_no_match, :assert_not_match

    def assert_nil(object, desc=nil)
      msg = "Expected nil, not #{object.inspect}."
      assert(object.nil?, desc, msg)
    end

    def assert_not_nil(object, desc=nil)
      msg = "Expected #{object.inspect} to not be nil."
      assert(!object.nil?, desc, msg)
    end
    alias_method :refute_nil, :assert_not_nil

    def assert_raises(*exceptions, &block)
      desc = exceptions.last.kind_of?(String) ? exceptions.pop : nil
      err = RaisedException.new(exceptions, &block)
      assert(err.raised?, desc, err.msg)
    end
    alias_method :assert_raise, :assert_raises

    def assert_nothing_raised(*exceptions, &block)
      desc = exceptions.last.kind_of?(String) ? exceptions.pop : nil
      err = NoRaisedException.new(exceptions, &block)
      assert(!err.raised?, desc, err.msg)
    end
    alias_method :assert_not_raises, :assert_nothing_raised
    alias_method :assert_not_raise, :assert_nothing_raised

    def assert_respond_to(method, object, desc=nil)
      msg = "Expected #{object.inspect} (#{object.class}) to"\
            " respond to `#{method}`."
      assert(object.respond_to?(method), desc, msg)
    end
    alias_method :assert_responds_to, :assert_respond_to

    def assert_not_respond_to(method, object, desc=nil)
      msg = "#{object.inspect} (#{object.class}) not expected to"\
            " respond to `#{method}`."
      assert(!object.respond_to?(method), desc, msg)
    end
    alias_method :assert_not_responds_to, :assert_not_respond_to
    alias_method :refute_respond_to, :assert_not_respond_to
    alias_method :refute_responds_to, :assert_not_respond_to

    def assert_same(expected, actual, desc=nil)
      msg = "Expected #{actual} (#{actual.object_id}) to"\
            " be the same as #{expected} (#{expected.object_id})."
      assert(actual.equal?(expected), desc, msg)
    end

    def assert_not_same(expected, actual, desc=nil)
      msg = "#{actual} (#{actual.object_id}) not expected to"\
            " be the same as #{expected} (#{expected.object_id})."
      assert(!actual.equal?(expected), desc, msg)
    end
    alias_method :refute_same, :assert_not_same

    # ignored assertion helpers

    IGNORED_ASSERTION_HELPERS = [
      :assert_throws,     :assert_nothing_thrown,
      :assert_operator,   :refute_operator,
      :assert_in_epsilon, :refute_in_epsilon,
      :assert_in_delta,   :refute_in_delta,
      :assert_send
    ]
    def method_missing(method, *args, &block)
      if IGNORED_ASSERTION_HELPERS.include?(method.to_sym)
        ignore "The assertion `#{method}` is not supported."\
               " Please use another assertion or the basic `assert`."
      else
        super
      end
    end

    # exception raised utility classes

    class CheckException
      attr_reader :msg, :exception

      def initialize(exceptions, &block)
        @exceptions = exceptions
        begin; block.call; rescue Exception => @exception; end
        @msg = "#{exceptions_sentence(@exceptions)} #{exception_details}"
      end

      def raised?
        !@exception.nil? && is_one_of?(@exception, @exceptions)
      end

      private

      def is_one_of?(exception, exceptions)
        exceptions.empty? || exceptions.any? do |exp|
          exp.instance_of?(Module) ? exception.kind_of?(exp) : exception.class == exp
        end
      end

      def exceptions_sentence(exceptions)
        if exceptions.size <= 1
          (exceptions.first || "An").to_s
        else
          "#{exceptions[0..-2].join(", ")} or #{exceptions[-1]}"
        end
      end

      def exception_details(raised_msg=nil, no_raised_msg=nil)
        if @exception
          backtrace = Assert::Result::Backtrace.new(@exception.backtrace)
          [ raised_msg,
            "Class: <#{@exception.class}>",
            "Message: <#{@exception.message.inspect}>",
            "---Backtrace---",
            backtrace.filtered.to_s,
            "---------------"
          ].compact.join("\n")
        else
          no_raised_msg
        end
      end
    end

    class RaisedException < CheckException
      def exception_details
        super("exception expected, not:", "exception expected but nothing raised.")
      end
    end

    class NoRaisedException < CheckException
      def exception_details
        super("exception not expected, but raised:")
      end
    end

  end
end
