require "assert"
require "assert/assertions"

module Assert::Assertions
  class AssertRaisesTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_raises`"
    subject { test1 }

    let(:desc1) { "assert raises fail desc" }
    let(:test1) {
      desc = desc1
      Factory.test do
        assert_raises(StandardError, RuntimeError) { raise(StandardError) }    # pass
        assert_raises(StandardError, RuntimeError, desc) { raise(Exception) }  # fail
        assert_raises(RuntimeError, desc) { raise(StandardError) }             # fail
        assert_raises(RuntimeError, desc) { true }                             # fail
        assert_raises(desc) { true }                                           # fail
      end
    }

    should "produce results as expected" do
      subject.run(&test_run_callback)

      assert_equal 5, test_run_result_count
      assert_equal 1, test_run_result_count(:pass)
      assert_equal 4, test_run_result_count(:fail)

      exp =
        [ "#{desc1}\nStandardError or RuntimeError exception expected, not:",
          "#{desc1}\nRuntimeError exception expected, not:",
          "#{desc1}\nRuntimeError exception expected but nothing raised.",
          "#{desc1}\nAn exception expected but nothing raised."
        ]
      messages = test_run_results(:fail).map(&:message)
      messages.each_with_index{ |msg, n| assert_match(/^#{exp[n]}/, msg) }
    end

    should "return any raised exception instance" do
      error     = nil
      error_msg = Factory.string

      test =
        Factory.test do
          error = assert_raises(RuntimeError) { raise(RuntimeError, error_msg) }
        end
      test.run

      assert_not_nil error
      assert_kind_of RuntimeError, error
      assert_equal error_msg, error.message

      test = Factory.test { error = assert_raises(RuntimeError) {} }
      test.run

      assert_nil error
    end
  end

  class AssertNothingRaisedTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_nothing_raised`"
    subject { test1 }

    let(:desc1) { "assert nothing raised fail desc" }
    let(:test1) {
      desc = desc1
      Factory.test do
        assert_nothing_raised(StandardError, RuntimeError, desc) { raise(StandardError) } # fail
        assert_nothing_raised(RuntimeError) { raise(StandardError) }                      # pass
        assert_nothing_raised(desc) { raise(RuntimeError) }                               # fail
        assert_nothing_raised { true }                                                    # pass
      end
    }

    should "produce results as expected" do
      subject.run(&test_run_callback)

      assert_equal 4, test_run_result_count
      assert_equal 2, test_run_result_count(:pass)
      assert_equal 2, test_run_result_count(:fail)

      exp =
        [ "#{desc1}\nStandardError or RuntimeError exception not expected, but raised:",
          "#{desc1}\nAn exception not expected, but raised:"
        ]
      messages = test_run_results(:fail).map(&:message)
      messages.each_with_index{ |msg, n| assert_match(/^#{exp[n]}/, msg) }
    end
  end
end
