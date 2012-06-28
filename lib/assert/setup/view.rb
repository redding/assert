require 'assert/setup/helpers'
require 'assert/view/default_view'

module Assert

  # Setup the default view, rendering on $stdout
  # (override in user or package helpers)
  options do
    default_view View::DefaultView.new($stdout)
  end

  def self.view; self.options.view; end

  module View

    # this method is used to bring in custom user-specific views
    # require views by passing either a full path to the view ruby file
    # or passing the name of a view installed in ~/.assert/views

    def self.require_user_view(view)
      user_test_root = File.expand_path(Assert::Helpers::USER_TEST_DIR, ENV['HOME'])
      views_file = File.join(user_test_root, 'views', view, 'lib', view)

      if File.exists?(view) || File.exists?(view+'.rb')
        require view
      elsif ENV['HOME'] && File.exists?(views_file+'.rb')
        require views_file
      else
        msg = "[WARN] Can't find or require #{view.inspect} view."
        if !view.match(/\A\//)
          msg << " Did you install it in `~/.assert/views`?"
        end
        warn msg
      end
    end

  end

end
