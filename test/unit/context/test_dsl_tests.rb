require 'assert'
require 'assert/context/test_dsl'

module Assert::Context::TestDSL

  class UnitTests < Assert::Context
    desc "Assert::Context::TestDSL"
    setup do
      @test_desc = "be true"
      @test_block = ::Proc.new{ assert(true) }
    end

    should "build a test using `test` with a desc and code block" do
      d, b = @test_desc, @test_block
      context, test = build_eval_context{ test(d, &b) }

      assert_equal 1, context.class.suite.tests_to_run_count

      assert_kind_of Assert::Test, test
      assert_equal @test_desc,  test.name
      assert_equal @test_block, test.code
    end

    should "build a test using `should` with a desc and code block" do
      d, b = @test_desc, @test_block
      context, test = build_eval_context{ should(d, &b) }

      assert_equal 1, context.class.suite.tests_to_run_count

      assert_kind_of Assert::Test, test
      assert_equal "should #{@test_desc}", test.name
      assert_equal @test_block, test.code
    end

    should "build a test that skips with no msg when `test_eventually` called" do
      d, b = @test_desc, @test_block
      context, test = build_eval_context{ test_eventually(d, &b) }
      err = capture_err(Assert::Result::TestSkipped) do
        context.instance_eval(&test.code)
      end

      assert_equal 1,      context.class.suite.tests_to_run_count
      assert_equal 'TODO', err.message
      assert_equal 1,      err.backtrace.size
    end

    should "build a test that skips with no msg  when `should_eventually` called" do
      d, b = @test_desc, @test_block
      context, test = build_eval_context{ should_eventually(d, &b) }
      err = capture_err(Assert::Result::TestSkipped) do
        context.instance_eval(&test.code)
      end

      assert_equal 1,      context.class.suite.tests_to_run_count
      assert_equal 'TODO', err.message
      assert_equal 1,      err.backtrace.size
    end

    should "skip with the msg \"TODO\" when `test` called with no block" do
      d = @test_desc
      context, test = build_eval_context { test(d) } # no block passed
      err = capture_err(Assert::Result::TestSkipped) do
        context.instance_eval(&test.code)
      end

      assert_equal 1,      context.class.suite.tests_to_run_count
      assert_equal 'TODO', err.message
      assert_equal 1,      err.backtrace.size
    end

    should "skip with the msg \"TODO\" when `should` called with no block" do
      d = @test_desc
      context, test = build_eval_context { should(d) } # no block passed
      err = capture_err(Assert::Result::TestSkipped) do
        context.instance_eval(&test.code)
      end

      assert_equal 1,      context.class.suite.tests_to_run_count
      assert_equal 'TODO', err.message
      assert_equal 1,      err.backtrace.size
    end

    should "skip with the msg \"TODO\" when `test_eventually` called with no block" do
      d = @test_desc
      context, test = build_eval_context{ test_eventually(d) } # no block given
      err = capture_err(Assert::Result::TestSkipped) do
        context.instance_eval(&test.code)
      end

      assert_equal 1,      context.class.suite.tests_to_run_count
      assert_equal 'TODO', err.message
      assert_equal 1,      err.backtrace.size
    end

    should "skip with the msg \"TODO\" when `should_eventually` called with no block" do
      d = @test_desc
      context, test = build_eval_context{ should_eventually(d) } # no block given
      err = capture_err(Assert::Result::TestSkipped) do
        context.instance_eval(&test.code)
      end

      assert_equal 1,      context.class.suite.tests_to_run_count
      assert_equal 'TODO', err.message
      assert_equal 1,      err.backtrace.size
    end

    should "build a test from a macro using `test`" do
      d, b = @test_desc, @test_block
      m = Assert::Macro.new{ test(d, &b); test(d, &b) }
      context_class = Factory.modes_off_context_class{ test(m) }

      assert_equal 2, context_class.suite.tests_to_run_count
    end

    should "build a test from a macro using `should`" do
      d, b = @test_desc, @test_block
      m = Assert::Macro.new{ should(d, &b); should(d, &b) }
      context_class = Factory.modes_off_context_class{ should(m) }

      assert_equal 2, context_class.suite.tests_to_run_count
    end

    should "build a test that skips from a macro using `test_eventually`" do
      d, b = @test_desc, @test_block
      m = Assert::Macro.new{ test(d, &b); test(d, &b) }
      context, test = build_eval_context{ test_eventually(m) }

      assert_equal 1, context.class.suite.tests_to_run_count
      assert_raises(Assert::Result::TestSkipped) do
        context.instance_eval(&test.code)
      end
    end

    should "build a test that skips from a macro using `should_eventually`" do
      d, b = @test_desc, @test_block
      m = Assert::Macro.new{ should(d, &b); should(d, &b) }
      context, test = build_eval_context{ should_eventually(m) }

      assert_equal 1, context.class.suite.tests_to_run_count
      assert_raises(Assert::Result::TestSkipped) do
        context.instance_eval(&test.code)
      end

    end

    private

    def build_eval_context(&build_block)
      context_class = Factory.modes_off_context_class &build_block
      test = context_class.suite.sorted_tests_to_run.to_a.last
      [context_class.new(test, test.config, proc{ |r| }), test]
    end

    def capture_err(err_class, &block)
      begin
        block.call
      rescue err_class => e
        e
      end
    end

  end

end
