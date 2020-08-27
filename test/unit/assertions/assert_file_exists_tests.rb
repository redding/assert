require "assert"
require "assert/assertions"

require "assert/utils"

module Assert::Assertions

  class AssertFileExistsTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_file_exists`"
    subject { test1 }

    let(:desc1) { "assert file exists fail desc" }
    let(:args1) { ["/a/path/to/some/file/that/no/exists", desc1] }
    let(:test1) {
      args = args1
      Factory.test do
        assert_file_exists(__FILE__) # pass
        assert_file_exists(*args)    # fail
      end
    }
    let(:config1) { test1.config }

    should "produce results as expected" do
      subject.run(&test_run_callback)

      assert_equal 2, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 1, test_run_result_count(:fail)

      exp = "#{args1[1]}\nExpected #{Assert::U.show(args1[0], config1)} to exist."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end

  class AssertNotFileExistsTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_not_file_exists`"
    subject { test1 }

    let(:desc1) { "assert not file exists fail desc" }
    let(:args1) { [__FILE__, desc1] }
    let(:test1) {
      args = args1
      Factory.test do
        assert_not_file_exists("/file/path") # pass
        assert_not_file_exists(*args)        # fail
      end
    }
    let(:config1) { test1.config }

    should "produce results as expected" do
      subject.run(&test_run_callback)

      assert_equal 2, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 1, test_run_result_count(:fail)

      exp = "#{args1[1]}\nExpected #{Assert::U.show(args1[0], config1)} to not exist."
      assert_equal exp, test_run_results(:fail).first.message
    end
  end
end
