require "much-stub"

module Assert; end
class Assert::ActualValue
  def self.not_given
    @not_given ||=
      Class.new {
        def to_s
          "Assert::ActualValue.not_given"
        end

        def blank?
          true
        end

        def present?
          false
        end

        def ==(other)
          if other.is_a?(self.class)
            true
          else
            super
          end
        end

        def inspect
          to_s
        end
      }.new
  end

  def self.not_given?(value)
    value == not_given
  end

  def self.given?(value)
    value != not_given
  end

  def initialize(value = self.class.not_given, context:, &value_block)
    @value = self.class.given?(value) ? value : value_block
    @context = context
  end

  def returns_true(*args)
    @context.assert_block(*args, &@value)
  end

  def does_not_return_true(*args)
    @context.assert_not_block(*args, &@value)
  end

  def raises(*expected_exceptions)
    @context.assert_raises(*expected_exceptions, &@value)
  end

  def does_not_raise(*expected_exceptions)
    @context.assert_nothing_raised(*expected_exceptions, &@value)
  end

  def is_a_kind_of(expected_class, *args)
    @context.assert_kind_of(expected_class, @value, *args)
  end
  alias_method :is_kind_of, :is_a_kind_of

  def is_not_a_kind_of(expected_class, *args)
    @context.assert_not_kind_of(expected_class, @value, *args)
  end
  alias_method :is_not_kind_of, :is_not_a_kind_of

  def is_an_instance_of(expected_class, *args)
    @context.assert_instance_of(expected_class, @value, *args)
  end
  alias_method :is_instance_of, :is_an_instance_of

  def is_not_an_instance_of(expected_class, *args)
    @context.assert_not_instance_of(expected_class, @value, *args)
  end
  alias_method :is_not_instance_of, :is_not_an_instance_of

  def responds_to(expected_method_name, *args)
    @context.assert_responds_to(expected_method_name, @value, *args)
  end

  def does_not_respond_to(expected_method_name, *args)
    @context.assert_not_responds_to(expected_method_name, @value, *args)
  end

  def is_the_same_as(expected_object, *args)
    @context.assert_same(expected_object, @value, *args)
  end
  alias_method :is, :is_the_same_as

  def is_not_the_same_as(expected_object, *args)
    @context.assert_not_same(expected_object, @value, *args)
  end
  alias_method :is_not, :is_not_the_same_as

  def equals(expected_value, *args)
    @context.assert_equal(expected_value, @value, *args)
  end
  alias_method :is_equal_to, :equals

  def does_not_equal(expected_value, *args)
    @context.assert_not_equal(expected_value, @value, *args)
  end
  alias_method :is_not_equal_to, :does_not_equal

  def matches(expected_regex, *args)
    @context.assert_match(expected_regex, @value, *args)
  end

  def does_not_match(expected_regex, *args)
    @context.assert_not_match(expected_regex, @value, *args)
  end

  def is_empty(*args)
    @context.assert_empty(@value, *args)
  end

  def is_not_empty(*args)
    @context.assert_not_empty(@value, *args)
  end

  def includes(object, *args)
    @context.assert_includes(object, @value, *args)
  end

  def does_not_include(object, *args)
    @context.assert_not_includes(object, @value, *args)
  end

  def is_nil(*args)
    @context.assert_nil(@value, *args)
  end

  def is_not_nil(*args)
    @context.assert_not_nil(@value, *args)
  end

  def is_true(*args)
    @context.assert_true(@value, *args)
  end

  def is_not_true(*args)
    @context.assert_not_true(@value, *args)
  end

  def is_false(*args)
    @context.assert_false(@value, *args)
  end

  def is_not_false(*args)
    @context.assert_not_false(@value, *args)
  end

  def is_a_file(*args)
    @context.assert_file_exists(@value, *args)
  end

  def is_not_a_file(*args)
    @context.assert_not_file_exists(@value, *args)
  end
end
