require 'assert/rake_tasks/scope'

module Assert::RakeTasks

  class TestTask

    attr_accessor :name, :path, :files

    # Create a testing task
    def initialize(path)
      @path = path
      @files = []
      yield self if block_given?
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

    def name
      File.basename(@path, Scope.test_file_suffix).to_sym
    end

    def file_list # :nodoc:
      self.files.collect{|f| "\"#{f}\""}.join(' ')
    end

    def ruby_args
      [ "\"#{self.rake_loader}\"",
        self.file_list
      ].compact.join(" ")
    end

    protected

    def rake_loader
      find_file('rake/rake_test_loader')
    end

    def find_file(fn) # :nodoc:
      $LOAD_PATH.each do |path|
        file_path = File.join(path, "#{fn}.rb")
        return file_path if File.exist? file_path
      end
      nil
    end

  end

end
