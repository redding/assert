require "assert"
require "assert/assertions"

module Assert::Assertions
  class AssertRaisesTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_raises`"
    subject {
      desc = desc1
      Factory.test do
        assert_raises(StandardError, RuntimeError) { raise(StandardError) }    # pass
        assert_raises(StandardError, RuntimeError, desc) { raise(Exception) }  # fail
        assert_raises(RuntimeError, desc) { raise(StandardError) }             # fail
        assert_raises(RuntimeError, desc) { true }                             # fail
        assert_raises(desc) { true }                                           # fail
      end
    }

    let(:desc1) { "assert raises fail desc" }

    should "produce results as expected" do
      subject.run(&test_run_callback)

      assert_that(test_run_result_count).equals(5)
      assert_that(test_run_result_count(:pass)).equals(1)
      assert_that(test_run_result_count(:fail)).equals(4)

      exp =
        [ "#{desc1}\nStandardError or RuntimeError exception expected, not:",
          "#{desc1}\nRuntimeError exception expected, not:",
          "#{desc1}\nRuntimeError exception expected but nothing raised.",
          "#{desc1}\nAn exception expected but nothing raised."
        ]
      messages = test_run_results(:fail).map(&:message)
      messages.each_with_index{ |msg, n| assert_that(msg).matches(/^#{exp[n]}/) }
    end

    should "return any raised exception instance" do
      error     = nil
      error_msg = Factory.string

      test =
        Factory.test do
          error = assert_raises(RuntimeError) { raise(RuntimeError, error_msg) }
        end
      test.run

      assert_that(error).is_not_nil
      assert_that(error).is_kind_of(RuntimeError)
      assert_that(error.message).equals(error_msg)

      test = Factory.test { error = assert_raises(RuntimeError) {} }
      test.run

      assert_that(error).is_nil
    end
  end

  class AssertNothingRaisedTests < Assert::Context
    include Assert::Test::TestHelpers

    desc "`assert_nothing_raised`"
    subject {
      desc = desc1
      Factory.test do
        assert_nothing_raised(StandardError, RuntimeError, desc) { raise(StandardError) } # fail
        assert_nothing_raised(RuntimeError) { raise(StandardError) }                      # pass
        assert_nothing_raised(desc) { raise(RuntimeError) }                               # fail
        assert_nothing_raised { true }                                                    # pass
      end
    }

    let(:desc1) { "assert nothing raised fail desc" }

    should "produce results as expected" do
      subject.run(&test_run_callback)

      assert_that(test_run_result_count).equals(4)
      assert_that(test_run_result_count(:pass)).equals(2)
      assert_that(test_run_result_count(:fail)).equals(2)

      exp =
        [ "#{desc1}\nStandardError or RuntimeError exception not expected, but raised:",
          "#{desc1}\nAn exception not expected, but raised:"
        ]
      messages = test_run_results(:fail).map(&:message)
      messages.each_with_index{ |msg, n| assert_that(msg).matches(/^#{exp[n]}/) }
    end
  end
end
