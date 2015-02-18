module Assert

  class FileLine

    def self.parse(file_line_path)
      self.new(*file_line_path.match(/(.+)\:(.+)/)[1..2])
    end

    attr_reader :file, :line

    def initialize(file, line)
      @file, @line = file.to_s, line.to_s
    end

    def to_s
      "#{self.file}:#{self.line}"
    end

    def ==(other_file_line)
      self.file == other_file_line.file && self.line == other_file_line.line
    end

  end

end
