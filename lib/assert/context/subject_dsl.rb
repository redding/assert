# frozen_string_literal: true

module Assert; end
class Assert::Context; end

module Assert::Context::SubjectDSL
  # Add a piece of description text or return the full description for the context
  def description(text = nil)
    if text
      self.descriptions << text.to_s
    else
      parent = self.superclass.desc if self.superclass.respond_to?(:desc)
      own = self.descriptions
      [parent, *own].compact.reject(&:empty?).join(" ")
    end
  end
  alias_method :desc, :description
  alias_method :describe, :description

  def subject(&block)
    if block_given?
      @subject = block
    else
      @subject || if superclass.respond_to?(:subject)
        superclass.subject
      end
    end
  end

  protected

  def descriptions
    @descriptions ||= []
  end
end
