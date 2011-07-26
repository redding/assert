require 'test_belt'
require 'assert/result'

class Assert::Assertion
  class BaseTest < Test::Unit::TestCase
    include TestBelt

    context "a base result"
    subject { Assert::Result::Base.new "a result" }

    should have_readers :message

    RESULTS = [:pass?, :fail?, :error?, :skip?]
    should have_instance_methods *RESULTS

    RESULTS.each do |meth|
      should "not know if #{meth}" do
        assert_raises(NotImplementedError) { subject.send(meth) }
      end
    end

  end
end
