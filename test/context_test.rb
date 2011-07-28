require 'test_belt'
require 'assert/context'

class Assert::Context

  class BasicTest < Test::Unit::TestCase
    include TestBelt

    context "a context"
    subject { Assert::Context.new }

  end

end