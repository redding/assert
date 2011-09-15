require 'rake/tasklib'

module Assert::RakeTasks

  class TestTask# < Rake::TaskLib

    attr_accessor :name, :path, :files

    # Create a testing task
    def initialize(name, path='')
      @name = name
      @path = path
      @files = []
    end

    def relative_path
      File.join(@path.to_s.split(File::SEPARATOR)[1..-1])
    end

    def scope_description
      relative_path.empty? ? "" : " for #{relative_path}"
    end

    def description
      "Run all tests#{scope_description}"
    end

    # def to_task
    #   desc @description
    #   task @name do
    #     RakeFileUtils.verbose(true) { ruby self.ruby_args }
    #   end
    # end

    def file_list # :nodoc:
      self.files.collect{|f| "\"#{f}\""}.join(' ')
    end

    def ruby_args
      [ ("-rrubygems" if !self.bundler_detected?),
        "\"#{self.rake_loader}\"",
        self.file_list
      ].compact.join(" ")
    end

    protected

    def rake_loader # :nodoc:
      find_file('rake/rake_test_loader') or
        fail "unable to find rake test loader"
    end

    def find_file(fn) # :nodoc:
      $LOAD_PATH.each do |path|
        file_path = File.join(path, "#{fn}.rb")
        return file_path if File.exist? file_path
      end
      nil
    end

    def bundler_detected?
      begin
        ::Bundler
        true
      rescue NameError => err
        false
      end
    end
  end

end
