# frozen_string_literal: true

module Assert
  class FileLine
    def self.parse(file_line_path)
      self.new(*(file_line_path.to_s.match(/(^[^\:]*)\:*(\d*).*$/) || [])[1..2])
    end

    attr_reader :file, :line

    def initialize(file = nil, line = nil)
      @file, @line = file.to_s, line.to_s
    end

    def to_s
      "#{self.file}:#{self.line}"
    end

    def ==(other_file_line)
      if other_file_line.kind_of?(FileLine)
        self.file == other_file_line.file &&
        self.line == other_file_line.line
      else
        super
      end
    end
  end
end
