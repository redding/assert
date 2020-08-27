require "assert"
require "assert/assertions"

require "assert/utils"

module Assert::Assertions
  class AssertEmptyTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_empty`"
    subject { test1 }

    let(:desc1) { "assert empty fail desc" }
    let(:args1) { [[1], desc1] }
    let(:test1) {
      args = args1
      Factory.test do
        assert_empty([])    # pass
        assert_empty(*args) # fail
      end
    }
    let(:config1) { test1.config }

    should "produce results as expected" do
      subject.run(&test_run_callback)

      assert_equal 2, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 1, test_run_result_count(:fail)

      exp =
        "#{args1[1]}\nExpected #{Assert::U.show(args1[0], config1)} to be empty."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end

  class AssertNotEmptyTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_empty`"
    subject { test1 }

    let(:desc1) { "assert not empty fail desc" }
    let(:args1) { [[], desc1] }
    let(:test1) {
      args = args1
      Factory.test do
        assert_not_empty([1])   # pass
        assert_not_empty(*args) # fail
      end
    }
    let(:config1) { test1.config }

    should "produce results as expected" do
      subject.run(&test_run_callback)

      assert_equal 2, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 1, test_run_result_count(:fail)

      exp =
        "#{args1[1]}\nExpected #{Assert::U.show(args1[0], config1)} to not be empty."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end
end
