require "assert"
require "assert/assertions"

require "assert/utils"

module Assert::Assertions
  class AssertIncludesTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_includes`"
    subject { test1 }

    let(:desc1) { "assert includes fail desc" }
    let(:args1) { [2, [1], desc1] }
    let(:test1) {
      args = args1
      Factory.test do
        assert_includes(1, [1]) # pass
        assert_includes(*args)  # fail
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
        "Expected #{Assert::U.show(args1[1], config1)}"\
        " to include #{Assert::U.show(args1[0], config1)}."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end

  class AssertNotIncludedTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_included`"
    subject { test1 }

    let(:desc1) { "assert not included fail desc" }
    let(:args1) { [1, [1], desc1] }
    let(:test1) {
      args = args1
      Factory.test do
        assert_not_included(2, [1]) # pass
        assert_not_included(*args)  # fail
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
        "Expected #{Assert::U.show(args1[1], config1)}"\
        " to not include #{Assert::U.show(args1[0], config1)}."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end
end
