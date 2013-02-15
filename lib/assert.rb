require 'singleton'

module Assert; end

require 'assert/view'
require 'assert/suite'
require 'assert/runner'
require 'assert/context'

module Assert

  def self.view;   Config.view;   end
  def self.suite;  Config.suite;  end
  def self.runner; Config.runner; end

  def self.config; Config; end
  def self.configure; yield Config if block_given?; end

  def self.init(test_dir)
    helper_file = File.join(test_dir, Config.test_helper)
    require helper_file if File.exists?(helper_file)
  end

  class Config
    include Singleton
    # map any class methods to the singleton
    def self.method_missing(m, *a, &b); self.instance.send(m, *a, &b); end
    def self.respond_to?(m); super || self.instance.respond_to?(m); end

    def self.settings(*values)
      values.each do |value|
        define_method(value) do |*args|
          instance_variable_set("@#{value}", args.first) if !args.first.nil?
          instance_variable_get("@#{value}")
        end
      end
    end

    settings :view, :suite, :runner
    settings :runner_seed, :output, :halt_on_fail, :test_dir, :test_helper

    def initialize
      @view   = Assert::View::DefaultView.new($stdout)
      @suite  = Assert::Suite.new
      @runner = Assert::Runner.new

      @runner_seed = begin # TODO: secure random??
        srand
        srand % 0xFFFF
      end.to_i
      @output = true
      @halt_on_fail = true
      @test_dir = "test"
      @test_helper = "helper.rb"
    end

  end

end
