require 'date'
require 'time'

module Assert

  module Factory
    extend self

    def integer(max = nil)
      self.type_cast(Random.integer(max), :integer)
    end

    def float(max = nil)
      self.type_cast(Random.float(max), :float)
    end

    DAYS_IN_A_YEAR = 365
    SECONDS_IN_DAY = 24 * 60 * 60

    def date
      @date ||= self.type_cast(Random.date_string, :date)
      @date + Random.integer(DAYS_IN_A_YEAR)
    end

    def time
      @time ||= self.type_cast(Random.time_string, :time)
      @time + (Random.float(DAYS_IN_A_YEAR) * SECONDS_IN_DAY).to_i
    end

    def datetime
      @datetime ||= self.type_cast(Random.datetime_string, :datetime)
      @datetime + (Random.float(DAYS_IN_A_YEAR) * SECONDS_IN_DAY).to_i
    end

    def string(length = nil)
      self.type_cast(Random.string(length || 10), :string)
    end

    def text(length = nil)
      self.type_cast(Random.string(length || 20), :string)
    end

    def slug(length = nil)
      self.type_cast(Random.string(length || 5), :string)
    end

    def hex(length = nil)
      self.type_cast(Random.hex_string(length), :string)
    end

    def file_name(length = nil)
      self.type_cast(Random.file_name_string(length), :string)
    end

    def dir_path(length = nil)
      self.type_cast(Random.dir_path_string(length), :string)
    end

    def file_path
      self.type_cast(Random.file_path_string, :string)
    end

    alias_method :path, :dir_path

    def url(host = nil, length = nil)
      self.type_cast(Random.url_string(host, length), :string)
    end

    def email(domain = nil, length = nil)
      self.type_cast(Random.email_string(domain, length), :string)
    end

    def binary
      self.type_cast(Random.binary, :binary)
    end

    def boolean
      self.type_cast(Random.integer.even?, :boolean)
    end

    def type_cast(value, type)
      self.type_converter.send(type, value)
    end

    def type_converter; TypeConverter; end

    module TypeConverter
      def self.string(input);    input.to_s;                 end
      def self.integer(input);   input.to_i;                 end
      def self.float(input);     input.to_f;                 end
      def self.datetime(input);  DateTime.parse(input.to_s); end
      def self.time(input);      Time.parse(input.to_s);     end
      def self.date(input);      Date.parse(input.to_s);     end
      def self.boolean(input);   !!input;                    end
      def self.binary(input);    input;                      end
    end

    module Random
      def self.integer(max = nil)
        rand(max || 32_766) + 1
      end

      # `rand` with no args gives a float between 0 and 1
      def self.float(max = nil)
        (self.integer((max || 100) - 1) + rand).to_f
      end

      def self.date_string
        Time.now.strftime("%Y-%m-%d")
      end

      def self.datetime_string
        Time.now.strftime("%Y-%m-%d %H:%M:%S")
      end

      def self.time_string
        Time.now.strftime("%H:%M:%S")
      end

      DICTIONARY = [*'a'..'z'].freeze
      def self.string(length = nil)
        [*0..((length || 10) - 1)].map{ |n| DICTIONARY[rand(DICTIONARY.size)] }.join
      end

      def self.hex_string(length = nil)
        length ||= 10
        self.integer(("f" * length).hex - 1).to_s(16).rjust(length, '0')
      end

      def self.file_name_string(length = nil)
        length ||= 6
        "#{self.string(length)}.#{self.string(3)}"
      end

      def self.dir_path_string(length = nil)
        length ||= 12
        File.join(*self.string(length).scan(/.{1,4}/))
      end

      def self.file_path_string
        File.join(self.dir_path_string, self.file_name_string)
      end

      def self.url_string(host = nil, length = nil)
        File.join(host.to_s, self.dir_path_string(length))
      end

      def self.email_string(domain = nil, length = nil)
        domain ||= "#{self.string(5)}.com"
        "#{self.string(length)}@#{domain}"
      end

      def self.binary
        [ self.integer(10000) ].pack('N*')
      end
    end

  end

end
