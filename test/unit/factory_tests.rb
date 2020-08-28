require "assert"
require "assert/factory"

require "much-factory"

module Assert::Factory
  class UnitTests < Assert::Context
    desc "Assert::Factory"
    subject { Assert::Factory }

    should "include and extend MuchFactory" do
      assert_that(subject).includes(MuchFactory)

      # https://stackoverflow.com/questions/5197166/ruby-get-a-list-of-extended-modules
      assert_that(subject_metaclass.included_modules).includes(MuchFactory)
    end

    private

    def subject_metaclass
      class << subject
        self
      end
    end
  end
end
