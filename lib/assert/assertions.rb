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

    # TODO: skip exception handling, see minitest assertion
    def assert_raises(*args)
      msg = String === args.last ? args.pop : nil
      msg = msg.to_s + "\n" if msg
      exceptions = args
      begin
        yield
      rescue Exception => exception
        details = "#{msg}#{exceptions_sentence(exceptions)} exception expected, not:"
        pass = exceptions.any? do |exp|
          exp.instance_of?(Module) ? exception.kind_of?(exp) : exp == exception.class
        end
        assert(pass, exception_details(exception, details))
        exception
      else
        assertion_result do
          fail("#{msg}#{exceptions_sentence(exceptions)} expected but nothing was raised.")
        end
      end
    end
    alias_method :assert_raise, :assert_raises

    # TODO: not supported in minitest
    def assert_nothing_raised(*args)
      msg = String === args.last ? args.pop : nil
      msg = msg.to_s + "\n" if msg
      exceptions = args
      begin
        yield
      rescue Exception => exception
        details = "#{msg}#{exceptions_sentence(exceptions)} not expected, but was raised:"
        fail = (exceptions.empty? || exceptions.any? do |exp|
          exp.instance_of?(Module) ? exception.kind_of?(exp) : exp == exception.class
        end)
        assert(!fail, exception_details(exception, details))
        exception
      else
        assertion_result{ pass }
      end
    end
    alias_method :assert_not_raises, :assert_nothing_raised
    alias_method :assert_not_raise, :assert_nothing_raised

    def assert_kind_of(klass, instance, fail_desc=nil)
      what_failed_msg = "Expected #{instance.inspect} to be a kind of #{klass}, not #{instance.class}"
      assert(instance.kind_of?(klass), fail_desc, what_failed_msg)
    end

    def refute_kind_of
    end


    def assert_instance_of(klass, instance, fail_desc=nil)
      what_failed_msg = "Expected #{instance.inspect} to be an instance of #{klass}, not #{instance.class}"
      assert(instance.instance_of?(klass), fail_desc, what_failed_msg)
    end

    def refute_instance_of
    end


    def assert_respond_to(object, method, fail_desc=nil)
      what_failed_msg = "Expected #{object.inspect} (#{object.class}) to respond to ##{method}"
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

    # from minitest
    # TODO: without filtered backtrace
    def exception_details(exception, msg)
      [ msg,
        "Class: <#{exception.class}>",
        "Message: <#{exception.message.inspect}>",
        "---Backtrace---",
        exception.backtrace.join("\n"),
        "---------------"
      ].join("\n")
    end

    def exceptions_sentence(exceptions)
      if exceptions.size == 1
        exceptions.first.to_s
      else
        "#{exceptions[0..-2].join(", ")} or #{exceptions[-1]}"
      end
    end

  end
end
