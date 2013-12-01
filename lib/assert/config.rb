module Assert

  class Config

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

    settings :view, :suite, :runner
    settings :test_dir, :test_helper, :runner_seed
    settings :changed_proc, :pp_proc, :use_diff_proc, :run_diff_proc
    settings :capture_output, :halt_on_fail, :changed_only, :pp_objects, :debug

    def initialize(settings = nil)
      @suite  = Assert::Suite.new(self)
      @view   = Assert::View::DefaultView.new($stdout, self, @suite)
      @runner = Assert::Runner.new(self)

      @test_dir    = "test"
      @test_helper = "helper.rb"
      @runner_seed   = begin; srand; srand % 0xFFFF; end.to_i

      @changed_proc  = Assert::AssertRunner::DEFAULT_CHANGED_FILES_PROC
      @pp_proc       = Assert::U.stdlib_pp_proc
      @use_diff_proc = Assert::U.default_use_diff_proc
      @run_diff_proc = Assert::U.syscmd_diff_proc

      # mode flags
      @capture_output = false
      @halt_on_fail   = true
      @changed_only   = false
      @pp_objects     = false
      @debug          = false

      self.apply(settings || {})
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
