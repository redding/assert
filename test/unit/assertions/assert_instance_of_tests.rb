require "assert"
require "assert/assertions"

require "assert/utils"

module Assert::Assertions
  class AssertInstanceOfTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_instance_of`"
    subject { test1 }

    let(:desc1) { "assert instance of fail desc" }
    let(:args1) { [Array, "object", desc1] }
    let(:test1) {
      args = args1
      Factory.test do
        assert_instance_of(String, "object") # pass
        assert_instance_of(*args)            # fail
      end
    }
    let(:config1) { test1.config }

    should "produce results as expected" do
      subject.run(&test_run_callback)

      assert_equal 2, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 1, test_run_result_count(:fail)

      exp =
        "#{args1[2]}\nExpected #{Assert::U.show(args1[1], config1)} (#{args1[1].class})"\
        " to be an instance of #{args1[0]}."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end

  class AssertNotInstanceOfTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_instance_of`"
    subject { test1 }

    let(:desc1) { "assert not instance of fail desc" }
    let(:args1) { [String, "object", desc1] }
    let(:test1) {
      args = args1
      Factory.test do
        assert_not_instance_of(*args)           # fail
        assert_not_instance_of(Array, "object") # pass
      end
    }
    let(:config1) { test1.config }

    should "produce results as expected" do
      subject.run(&test_run_callback)

      assert_equal 2, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 1, test_run_result_count(:fail)

      exp =
        "#{args1[2]}\nExpected #{Assert::U.show(args1[1], config1)} (#{args1[1].class})"\
        " to not be an instance of #{args1[0]}."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end
end
