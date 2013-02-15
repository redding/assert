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

      @test_paths = test_paths
      @test_paths << Assert.config.test_dir if @test_paths.empty?
      @test_dir_root_path = test_dir_root_path(@test_paths.first)

      load_tests
    end

    def run
      Assert.init(File.join(@test_dir_root_path, Assert.config.test_dir))
      Assert.runner.run(Assert.suite, Assert.view)
    end

    protected

    def apply_user_settings
      safe_require("#{ENV['HOME']}/#{USER_SETTINGS_FILE}") if ENV['HOME']
    end

    def apply_local_settings
      # TODO: use ENV file or walk up Dir.pwd to `.assert.rb` file
    end

    def apply_option_settings(options)
      # TODO: drive assert config settings from given options (don't nils)
    end

    def apply_env_settings
      # TODO: drive assert config settings from env vars (don't nils)
    end

    def load_tests
      Assert.view.fire(:before_load)
      file_paths(@test_paths).select{ |p| test_file?(p) }.sort.each{ |p| require p }
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

    def test_dir_root_path(a_test_path)
      full_path = File.expand_path("./#{a_test_path}", Dir.pwd)
      test_dir_pos = full_path.index(dir_regex(Assert.config.test_dir))
      full_path[0..(test_dir_pos-1)] if test_dir_pos && (test_dir_pos > 0)
    end

    def dir_regex(dir); /^#{dir}$|^#{dir}\/|\/#{dir}\/|\/#{dir}$/; end


  end

end
