module Assert
  module Helpers

    # when Assert is required it will automatically require in two helper files
    # if they exist:
    # * "./test/helper.rb - package-specific helpers
    # * ~/.assert.rb - user-specific helpers (options, view, etc...)
    # the user-specific helper file will always be required in after the
    # package-specific one

    USER_TEST_DIR    = './.assert'
    USER_TEST_HELPER = 'options'

    class << self

      # assume the test dir path is ./test and look for helpers in ./test/helper.rb
      def package_test_dir
        "test"
      end
      def package_helper_name
        "helper"
      end
      def package_test_helper_regex
        /^#{package_test_dir}$|^#{package_test_dir}\/|\/#{package_test_dir}\/|\/#{package_test_dir}$/
      end

      def load(caller_info)
        if (crp = caller_root_path(caller_info))
          require_package_test_helper(crp)
        end
        require_user_test_helper
      end

      private

      def require_user_test_helper
        if ENV['HOME']
          helper_path = File.join(USER_TEST_DIR, USER_TEST_HELPER)
          safe_require File.expand_path(helper_path, ENV['HOME'])
        end
      end

      # require the package's test/helper file if it exists
      def require_package_test_helper(root_path)
        safe_require package_helper_file(root_path)
      end

      def package_helper_file(root_path)
        File.join(root_path, package_test_dir, package_helper_name)
      end

      def safe_require(helper_file)
        if File.exists?(helper_file+".rb")
          require helper_file
        end
      end

      # this method inspects the caller info and finds the caller's root path
      # this expects the caller's root path to be the parent dir of the first
      # parent dir of caller named TEST_DIR
      def caller_root_path(caller_info)
        non_custom_require_caller_info = caller_info.reject{|i| i =~ /rubygems\/custom_require.rb/}
        caller_dirname = File.expand_path(File.dirname(non_custom_require_caller_info[0]))
        test_dir_pos = caller_dirname.index(package_test_helper_regex)
        if test_dir_pos && (test_dir_pos > 0)
          caller_dirname[0..(test_dir_pos-1)]
        end
      end
    end

  end
end
