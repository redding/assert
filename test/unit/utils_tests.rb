require 'assert'
require 'assert/utils'

module Assert::Utils

  class UnitTests < Assert::Context
    desc "Assert::Utils"
    subject{ Assert::Utils }

    should have_imeths :pp

  end

  class PrettyPrintTests < UnitTests
    desc "`pp`"
    setup do
      @inputs = [ 1, 'hi there', Hash.new, [:a, :b]]
      @default_processor = Assert.config.pp_processor
      @new_processor = Proc.new{ |input| 'herp derp' }
    end
    teardown do
      Assert.config.pp_processor(@default_processor)
    end

    should "process its given input and encode if available" do
      @inputs.each do |input|
        assert_equal @default_processor.to_proc.call(input), subject.pp(input)
      end

      Assert.config.pp_processor(@new_processor)
      @inputs.each do |input|
        assert_equal @new_processor.to_proc.call(input), subject.pp(input)
      end
    end

  end

end
