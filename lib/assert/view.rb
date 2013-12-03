require 'assert/view/default_view'

module Assert::View

  # this method is used to bring in custom user-specific views
  # require views by passing either a full path to the view ruby file
  # or passing the name of a view installed in ~/.assert/views

  def self.require_user_view(view_name)
    views_file = File.expand_path(File.join('~/.assert/views', view_name, 'lib', view_name))

    if File.exists?(view_name) || File.exists?(view_name + '.rb')
      require view_name
    elsif File.exists?(views_file + '.rb')
      require views_file
    else
      msg = "[WARN] Can't find or require #{view_name.inspect} view."
      msg << " Did you install it in `~/.assert/views`?" if !view_name.match(/\A\//)
      warn msg
    end
  end

end
