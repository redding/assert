module Assert
  module Assertions

    def assert_block(fail_desc=nil)
      what_failed_msg ||= "Expected block to return true value."
      assert(yield, fail_desc, what_failed_msg)
    end

    def assert_not_block(fail_desc=nil)
      what_failed_msg ||= "Expected block to return false value."
      assert(!yield, fail_desc, what_failed_msg)
    end
    alias_method :refute_block, :assert_not_block



    def assert_raises(*args, &block)
      assertion, fail_desc = catch_exception_and_check(args, :raises, &block)
      assert(assertion, fail_desc, "")
    end
    alias_method :assert_raise, :assert_raises

    def assert_nothing_raised(*args, &block)
      assertion, fail_desc = catch_exception_and_check(args, :not_raises, &block)
      assert(!assertion, fail_desc, "")
    end
    alias_method :assert_not_raises, :assert_nothing_raised
    alias_method :assert_not_raise, :assert_nothing_raised



    def assert_kind_of(klass, instance, fail_desc=nil)
      what_failed_msg = "Expected #{instance.inspect} to be a kind of #{klass}, not #{instance.class}."
      assert(instance.kind_of?(klass), fail_desc, what_failed_msg)
    end

    def assert_not_kind_of(klass, instance, fail_desc=nil)
      what_failed_msg = "#{instance.inspect} was not expected to be a kind of #{klass}."
      assert(!instance.kind_of?(klass), fail_desc, what_failed_msg)
    end
    alias_method :refute_kind_of, :assert_not_kind_of



    def assert_instance_of(klass, instance, fail_desc=nil)
      what_failed_msg = "Expected #{instance.inspect} to be an instance of #{klass}, not #{instance.class}."
      assert(instance.instance_of?(klass), fail_desc, what_failed_msg)
    end

    def assert_not_instance_of(klass, instance, fail_desc=nil)
      what_failed_msg = "#{instance.inspect} was not expected to be an instance of #{klass}."
      assert(!instance.instance_of?(klass), fail_desc, what_failed_msg)
    end
    alias_method :refute_instance_of, :assert_not_instance_of
    
    

    def assert_respond_to(object, method, fail_desc=nil)
      what_failed_msg = "Expected #{object.inspect} (#{object.class}) to respond to ##{method}."
      assert(object.respond_to?(method), fail_desc, what_failed_msg)
    end

    def refute_respond_to
    end


    def assert_same
    end

    def refute_same
    end


    def assert_equal
    end

    def refute_equal
    end


    def assert_match
    end

    def refute_match
    end

    private

    # common stuff from assert_raises and assert_nothing_raised
    def catch_exception_and_check(args, which, &block)
      fail_desc = String === args.last ? args.pop : nil
      exceptions = args
      begin
        yield
      rescue Exception => exception
      end
      assertion, what_failed_msg = if exception
        test = exceptions.empty? || exceptions.any? do |exp|
          exp.instance_of?(Module) ? exception.kind_of?(exp) : exp == exception.class
        end
        [ test, exception_details(exception, which) ]
      else
        [ false, exception_details(exception, which) ]
      end
      what_failed_msg = "#{exceptions_sentence(exceptions)} #{what_failed_msg}"
      fail_desc = [ fail_desc, what_failed_msg ].compact.join("\n")
      [ assertion, fail_desc ]
    end

    # from minitest
    # TODO: without filtered backtrace
    def exception_details(exception, which)
      if exception
        what_failed_msg = case(which)
          when :raises
            "exception expected, not:"
          when :not_raises
            "exception was not expected, but was raised:"
        end
        [ what_failed_msg,
          "Class: <#{exception.class}>",
          "Message: <#{exception.message.inspect}>",
          "---Backtrace---",
          exception.backtrace.join("\n"),
          "---------------"
        ].compact.join("\n")
      else
        case(which)
        when :raises
          "exception expected but nothing was raised."
        end
      end
    end

    def exceptions_sentence(exceptions)
      if exceptions.size <= 1
        (exceptions.first || "An").to_s
      else
        "#{exceptions[0..-2].join(", ")} or #{exceptions[-1]}"
      end
    end

  end
end
