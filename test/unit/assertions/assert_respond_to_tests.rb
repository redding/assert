require "assert"
require "assert/assertions"

require "assert/utils"

module Assert::Assertions
  class AssertRespondToTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_respond_to`"
    subject { test1 }

    let(:desc1) { "assert respond to fail desc" }
    let(:args1) { [:abs, "1", desc1] }
    let(:test1) {
      args = args1
      Factory.test do
        assert_respond_to(:abs, 1) # pass
        assert_respond_to(*args)   # fail
      end
    }
    let(:config1) { test1.config }

    should "produce results as expected" do
      subject.run(&test_run_callback)

      assert_equal 2, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 1, test_run_result_count(:fail)

      exp =
        "#{args1[2]}\n"\
        "Expected #{Assert::U.show(args1[1], config1)} (#{args1[1].class})"\
        " to respond to `#{args1[0]}`."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end

  class AssertNotRespondToTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_respond_to`"
    subject { test1 }

    let(:desc1) { "assert not respond to fail desc" }
    let(:args1) { [:abs, 1, desc1] }
    let(:test1) {
      args = args1
      Factory.test do
        assert_not_respond_to(*args)     # fail
        assert_not_respond_to(:abs, "1") # pass
      end
    }
    let(:config1) { test1.config }

    should "produce results as expected" do
      subject.run(&test_run_callback)

      assert_equal 2, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 1, test_run_result_count(:fail)

      exp =
        "#{args1[2]}\n"\
        "Expected #{Assert::U.show(args1[1], config1)} (#{args1[1].class})"\
        " to not respond to `#{args1[0]}`."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end
end
