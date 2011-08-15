require 'assert/result'
require 'assert/result_set'

module Assert
  class Test

    # a Test is some code/method to run in the scope of a Context.  After a
    # a test runs, it should have some assertions which are its results.

    attr_reader :name, :code, :context_class
    attr_accessor :results

    def initialize(name, context_class, code = nil, &block)
      @context_class = context_class
      @name = name_from_context(name)
      @code = (code || block)
      @results = ResultSet.new
    end

    def run(view=nil)
      @results.view = view
      run_scope = @context_class.new(self)
      begin
        @context_class.setup(run_scope)
        if @code.kind_of?(::Proc)
          run_scope.instance_eval(&@code)
        elsif run_scope.respond_to?(@code.to_s)
          run_scope.send(@code.to_s)
        end
      rescue Result::TestSkipped => err
        @results << Result::Skip.new(self.name, err)
      rescue Exception => err
        @results << Result::Error.new(self.name, err)
      ensure
        begin
          @context_class.teardown(run_scope)
        rescue Exception => teardown_err
          @results << Result::Error.new(self.name, teardown_err)
        end
      end
      @results.view = nil
      @results
    end

    Assert::Result.types.each do |name, klass|
      define_method "#{name}_results" do
        @results.select{|r| r.kind_of?(klass) }
      end
    end

    def result_count(type=nil)
      if Assert::Result.types.include?(type)
        self.send("#{type}_results").size
      else
        @results.size
      end
    end

    def <=>(other_test)
      self.name <=> other_test.name
    end

    def inspect
      attributes_string = ([ :name, :context_class, :results ].collect do |attr|
        "@#{attr}=#{self.send(attr).inspect}"
      end).join(" ")
      "#<#{self.class} #{attributes_string}>"
    end

    protected

    def name_from_context(name)
      [ @context_class.description,
        name.gsub(/^test:\s+should/, "should")
      ].compact.reject{|p| p.empty?}.join(" ")
    end

  end
end
