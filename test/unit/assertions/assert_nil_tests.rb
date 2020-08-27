require "assert"
require "assert/assertions"

require "assert/utils"

module Assert::Assertions
  class AssertNilTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_nil`"
    subject { test1 }

    let(:desc1) { "assert nil empty fail desc" }
    let(:args1) { [1, desc1] }
    let(:test1) {
      args = args1
      Factory.test do
        assert_nil(nil)   # pass
        assert_nil(*args) # fail
      end
    }
    let(:config1) { test1.config }

    should "produce results as expected" do
      subject.run(&test_run_callback)

      assert_equal 2, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 1, test_run_result_count(:fail)

      exp = "#{args1[1]}\nExpected #{Assert::U.show(args1[0], config1)} to be nil."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end

  class AssertNotNilTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_nil`"
    subject { test1 }

    let(:desc1) { "assert not nil empty fail desc" }
    let(:args1) { [nil, desc1] }
    let(:test1) {
      args = args1
      Factory.test do
        assert_not_nil(1)     # pass
        assert_not_nil(*args) # fail
      end
    }
    let(:config1) { test1.config }

    should "produce results as expected" do
      subject.run(&test_run_callback)

      assert_equal 2, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 1, test_run_result_count(:fail)

      exp = "#{args1[1]}\nExpected #{Assert::U.show(args1[0], config1)} to not be nil."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end
end
