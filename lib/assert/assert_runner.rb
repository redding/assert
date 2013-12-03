require 'assert/cli'

module Assert

  class AssertRunner
    TEST_FILE_SUFFIXES  = ['_tests.rb', '_test.rb']
    USER_SETTINGS_FILE  = ".assert/init.rb"
    LOCAL_SETTINGS_FILE = ".assert.rb"

    DEFAULT_CHANGED_FILES_PROC = Proc.new do |test_paths|
      # use git to determine which files have changes
      files = []
      cmd = [
        "git diff --no-ext-diff --name-only",       # changed files
        "git ls-files --others --exclude-standard"  # added files
      ].map{ |c| "#{c} -- #{test_paths.join(' ')}" }.join(' && ')

      Assert::CLI.bench('Load only changed files') do
        files = `#{cmd}`.split("\n")
      end
      puts Assert::CLI.debug_msg("  `#{cmd}`") if Assert.config.debug
      files
    end

    def initialize(test_paths, test_options)
      Assert::CLI.bench('Apply settings') do
        apply_user_settings
        apply_local_settings
        apply_option_settings(test_options)
        apply_env_settings
      end

      files = test_files(test_paths.empty? ? [*Assert.config.test_dir] : test_paths)
      init(files, path_of(Assert.config.test_dir, files.first))
    end

    def init(test_files, test_dir)
      # load any test helper file
      if test_dir && (h = File.join(test_dir, Config.test_helper)) && File.exists?(h)
        Assert::CLI.bench('Require test helper'){ require h }
      end

      # load the test files
      Assert.view.fire(:before_load, test_files)
      Assert::CLI.bench("Require #{test_files.count} test files") do
        test_files.each{ |p| require p }
      end
      if Assert.config.debug
        puts Assert::CLI.debug_msg("Test files:")
        test_files.each{ |f| puts Assert::CLI.debug_msg("  #{f}") }
      end
      Assert.view.fire(:after_load)
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

    private

    def test_files(test_paths)
      file_paths = if Assert.config.changed_only
        changed_test_files(test_paths)
      else
        globbed_test_files(test_paths)
      end

      file_paths.select{ |p| is_test_file?(p) }.sort
    end

    def changed_test_files(test_paths)
      globbed_test_files(Assert.config.changed_proc.call(test_paths))
    end

    def globbed_test_files(test_paths)
      test_paths.inject(Set.new) do |paths, path|
        p = File.expand_path(path, Dir.pwd)
        paths += Dir.glob("#{p}*") + Dir.glob("#{p}*/**/*")
      end
    end

    def is_test_file?(path)
      TEST_FILE_SUFFIXES.inject(false) do |result, suffix|
        result || path =~ /#{suffix}$/
      end
    end

    def safe_require(settings_file)
      require settings_file if File.exists?(settings_file)
    end

    # this method inspects a test path and finds the test dir path.

    def path_of(segment, a_path)
      full_path = File.expand_path(a_path || '.', Dir.pwd)
      seg_pos = full_path.index(segment_regex(segment))
      File.join(seg_pos && (seg_pos > 0) ? full_path[0..(seg_pos-1)] : full_path, segment)
    end

    def segment_regex(seg); /^#{seg}$|^#{seg}\/|\/#{seg}\/|\/#{seg}$/; end

  end

end
