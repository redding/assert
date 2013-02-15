module Assert

  class AssertRunner
    TEST_FILE_SUFFIXES  = ['_tests.rb', '_test.rb']
    USER_SETTINGS_FILE  = ".assert/init.rb"
    LOCAL_SETTINGS_FILE = ".assert.rb"

    def initialize(test_paths, test_options)
      require 'assert'  # inits config singleton with the default settings

      apply_user_settings
      apply_local_settings
      apply_option_settings(test_options)
      apply_env_settings

      test_paths = test_paths
      test_paths << Assert.config.test_dir if test_paths.empty?
      Assert.init(path_of(Assert.config.test_dir, test_paths.first))
      load_tests(test_paths)
    end

    def run
      Assert.runner.run(Assert.suite, Assert.view)
    end

    protected

    def apply_user_settings
      safe_require("#{ENV['HOME']}/#{USER_SETTINGS_FILE}") if ENV['HOME']
    end

    def apply_local_settings
      safe_require(ENV['ASSERT_LOCALFILE'] || path_of(LOCAL_SETTINGS_FILE, Dir.pwd))
    end

    def apply_option_settings(options)
      Assert.config.apply(options)
    end

    def apply_env_settings
      Assert.configure do |c|
        c.runner_seed ENV['ASSERT_RUNNER_SEED'].to_i if ENV['ASSERT_RUNNER_SEED']
      end
    end

    def load_tests(paths)
      Assert.view.fire(:before_load)
      file_paths(paths).select{ |p| test_file?(p) }.sort.each{ |p| require p }
      Assert.view.fire(:after_load)
    end

    private

    def file_paths(test_paths)
      test_paths.inject(Set.new) do |paths, path|
        paths += Dir.glob("#{path}*") + Dir.glob("#{path}*/**/*")
      end
    end

    def test_file?(path)
      TEST_FILE_SUFFIXES.inject(false) do |result, suffix|
        result || path =~ /#{suffix}$/
      end
    end

    def safe_require(settings_file)
      require settings_file if File.exists?(settings_file)
    end

    # this method inspects a test path and finds the test dir path.

    def path_of(segment, a_path)
      full_path = File.expand_path(a_path)
      seg_pos = full_path.index(segment_regex(segment))
      File.join(seg_pos && (seg_pos > 0) ? full_path[0..(seg_pos-1)] : full_path, segment)
    end

    def segment_regex(seg); /^#{seg}$|^#{seg}\/|\/#{seg}\/|\/#{seg}$/; end

  end

end
