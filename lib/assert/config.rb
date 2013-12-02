module Assert

  class Config
    include Singleton
    # map any class methods to the singleton
    def self.method_missing(m, *a, &b); self.instance.send(m, *a, &b); end
    def self.respond_to?(m); super || self.instance.respond_to?(m); end

    def self.settings(*items)
      items.each do |item|
        define_method(item) do |*args|
          if !(value = args.size > 1 ? args : args.first).nil?
            instance_variable_set("@#{item}", value)
          end
          instance_variable_get("@#{item}")
        end
      end
    end

    settings :view, :suite, :runner, :test_dir, :test_helper, :changed_proc
    settings :runner_seed, :pp_proc, :use_diff_proc, :run_diff_proc
    settings :capture_output, :halt_on_fail, :changed_only, :pp_objects, :debug

    def initialize
      @view   = Assert::View::DefaultView.new($stdout)
      @suite  = Assert::Suite.new
      @runner = Assert::Runner.new
      @test_dir    = "test"
      @test_helper = "helper.rb"
      @changed_proc = Assert::AssertRunner::DEFAULT_CHANGED_FILES_PROC

      # default option values
      @runner_seed   = begin; srand; srand % 0xFFFF; end.to_i
      @pp_proc       = Assert::U.stdlib_pp_proc
      @use_diff_proc = Assert::U.default_use_diff_proc
      @run_diff_proc = Assert::U.syscmd_diff_proc

      # mode flags
      @capture_output = false
      @halt_on_fail   = true
      @changed_only   = false
      @pp_objects     = false
      @debug          = false
    end

    def apply(settings)
      settings.keys.each do |name|
        if !settings[name].nil? && self.respond_to?(name.to_s)
          self.send(name.to_s, settings[name])
        end
      end
    end

  end

end
