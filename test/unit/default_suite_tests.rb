require 'assert'
require 'assert/default_suite'

require 'assert/suite'

class Assert::DefaultSuite

  class UnitTests < Assert::Context
    desc "Assert::DefaultSuite"
    setup do
      @config = Factory.modes_off_config
      @suite  = Assert::DefaultSuite.new(@config)

      ci = Factory.context_info(Factory.modes_off_context_class)
      [ Factory.test("should nothing", ci){ },
        Factory.test("should pass",    ci){ assert(1==1); refute(1==0) },
        Factory.test("should fail",    ci){ ignore; assert(1==0); refute(1==1) },
        Factory.test("should ignored", ci){ ignore },
        Factory.test("should skip",    ci){ skip; ignore; assert(1==1) },
        Factory.test("should error",   ci){ raise Exception; ignore; assert(1==1) }
      ].each{ |test| @suite.tests << test }
      @suite.tests.each(&:run)
    end
    subject{ @suite }

    should "be a Suite" do
      assert_kind_of Assert::Suite, subject
    end

    should "know its test and result attrs" do
      assert_equal 6, subject.tests.size
      assert_kind_of Assert::Test, subject.tests.first

      assert_equal subject.tests.size, subject.test_count
      assert_equal subject.tests,      subject.ordered_tests

      exp = subject.ordered_tests.sort{ |a, b| a.run_time <=> b.run_time }
      assert_equal exp, subject.ordered_tests_by_run_time

      assert_equal 8, subject.result_count

      exp = subject.ordered_tests.inject([]){ |results, t| results += t.results }
      assert_equal exp, subject.ordered_results

      assert_equal 2, subject.result_count(:pass)
      assert_equal 2, subject.result_count(:fail)
      assert_equal 2, subject.result_count(:ignore)
      assert_equal 1, subject.result_count(:skip)
      assert_equal 1, subject.result_count(:error)
    end

    should "count its tests and results" do
      assert_equal subject.test_count,   subject.count(:tests)
      assert_equal subject.result_count, subject.count(:results)

      assert_equal subject.result_count(:pass), subject.count(:passed)
      assert_equal subject.result_count(:pass), subject.count(:pass)

      assert_equal subject.result_count(:fail), subject.count(:failed)
      assert_equal subject.result_count(:fail), subject.count(:fail)

      assert_equal subject.result_count(:ignore), subject.count(:ignored)
      assert_equal subject.result_count(:ignore), subject.count(:ignore)

      assert_equal subject.result_count(:skip), subject.count(:skipped)
      assert_equal subject.result_count(:skip), subject.count(:skip)

      assert_equal subject.result_count(:error), subject.count(:errored)
      assert_equal subject.result_count(:error), subject.count(:error)
    end

  end

end
