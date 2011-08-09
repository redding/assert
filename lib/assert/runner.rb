require 'assert/view/terminal'

module Assert
  class Runner

    # a Runner runs a suite of tests.

    def initialize(suite, output_io)
      raise ArgumentError if !suite.kind_of?(Suite)
      @suite = suite
      # TODO: specify other views
      @view = View::Terminal.new(@suite, output_io)
    end

    def run(*args)
      @view.render do
        benchmark { run_suite }
      end
      count(:failed) + count(:errored)
    end

    def count(type)
      @suite.count(type)
    end

    protected

    def tests_to_run
      tests = @suite.contexts

      # order tests randomly
      max = tests.size
      srand
      seed = srand % 0xFFFF
      srand seed
      #tests.sort.sort_by { rand max }
      tests
    end

    private

    def benchmark
      @suite.start_time = Time.now
      yield if block_given?
      @suite.end_time = Time.now
    end

    def run_suite
      # TODO: parallel running
      tests_to_run.each { |test| test.run }
    end

  end

end
