require 'assert/view/default_view'

module Assert::View

  # this method is used to bring in custom user-specific views
  # require views by passing either a full path to the view ruby file
  # or passing the name of a view installed in ~/.assert/views

  def self.require_user_view(view)
    views_file = File.join(Assert.config.user_test_dir, 'views', view, 'lib', view)

    if File.exists?(view) || File.exists?(view+'.rb')
      require view
    elsif File.exists?(views_file+'.rb')
      require views_file
    else
      msg = "[WARN] Can't find or require #{view.inspect} view."
      msg << " Did you install it in `~/.assert/views`?" if !view.match(/\A\//)
      warn msg
    end
  end

end
