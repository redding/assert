require 'assert'
require 'assert/factory'

module Assert::Factory

  class UnitTests < Assert::Context
    desc "Assert::Factory"
    subject{ Assert::Factory }

    should have_imeths :integer, :float
    should have_imeths :date, :time, :datetime
    should have_imeths :string, :text, :slug, :hex
    should have_imeths :file_name, :dir_path, :file_path
    should have_imeths :binary, :boolean
    should have_imeths :type_cast, :type_converter

    should "return a random integer using `integer`" do
      assert_kind_of Integer, subject.integer
    end

    should "allow passing a maximum value using `integer`" do
      assert_includes subject.integer(2), [ 1, 2 ]
    end

    should "return a random float using `float`" do
      assert_kind_of Float, subject.float
    end

    should "allow passing a maximum value using `float`" do
      float = subject.float(2)
      assert float <= 2
      assert float >= 1
    end

    should "return a random date using `date`" do
      assert_kind_of Date, subject.date
    end

    should "return a random time object using `time`" do
      assert_kind_of Time, subject.time
    end

    should "return a random time object using `datetime`" do
      assert_kind_of DateTime, subject.datetime
    end

    should "return a random string using `string`" do
      assert_kind_of String, subject.string
      assert_equal 10, subject.string.length
    end

    should "allow passing a maximum length using `string`" do
      assert_equal 1, subject.string(1).length
    end

    should "return a random string using `text`" do
      assert_kind_of String, subject.text
      assert_equal 20, subject.text.length
    end

    should "allow passing a maximum length using `text`" do
      assert_equal 1, subject.text(1).length
    end

    should "return a random hex string using `hex`" do
      assert_kind_of String, subject.hex
      assert_match /\A[0-9a-f]{10}\Z/, subject.hex
    end

    should "allow passing a maximum length using `hex`" do
      assert_equal 1, subject.hex(1).length
    end

    should "return a random slug string using `slug`" do
      assert_kind_of String, subject.slug
      segments = subject.slug.split('-')
      assert_equal 2, segments.size
      segments.each{ |s| assert_match /\A[a-z]{4}\Z/, s }
    end

    should "allow passing a maximum length using `slug`" do
      assert_equal 1, subject.slug(1).length
    end

    should "return a random file name string using `file_name`" do
      assert_kind_of String, subject.file_name
      assert_match /\A[a-z]{6}\.[a-z]{3}\Z/, subject.file_name
    end

    should "allow passing a name length using `file_name`" do
      assert_match /\A[a-z]{1}.[a-z]{3}\Z/, subject.file_name(1)
    end

    should "return a random folder path string using `dir_path`" do
      assert_kind_of String, subject.dir_path
      path_segments = subject.dir_path.split('/')
      assert_equal 3, path_segments.size
      path_segments.each{ |s| assert_match /\A[a-z]{4}\Z/, s }
    end

    should "allow passing a maximum length using `dir_path`" do
      assert_equal 1, subject.dir_path(1).length
    end

    should "return a random folder path and file name using `file_path`" do
      assert_kind_of String, subject.file_path
      segments = subject.file_path.split('/')
      assert_equal 4, segments.size
      segments[0..-2].each{ |s| assert_match /\A[a-z]{4}\Z/, s }
      assert_match /\A[a-z]{6}\.[a-z]{3}\Z/, segments.last
    end

    should "return a random binary string using `binary`" do
      assert_kind_of String, subject.binary
    end

    should "return a random boolean using `boolean`" do
      assert_includes subject.boolean.class, [ TrueClass, FalseClass ]
    end

    should "type cast values to a specified type using `type_cast`" do
      expected = Date.parse('2013-01-01')
      assert_equal expected, subject.type_cast('2013-01-01', :date)
    end

    should "use `TypedConverter` for the default type converter" do
      assert_equal TypeConverter, subject.type_converter
    end

  end

end
