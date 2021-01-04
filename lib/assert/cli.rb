# frozen_string_literal: true

require "benchmark"
require "set"
require "assert/assert_runner"
require "assert/version"

module Assert
  class CLI
    def self.debug?(args)
      args.include?("-d") || args.include?("--debug")
    end

    def self.debug_msg(msg)
      "[DEBUG] #{msg}"
    end

    def self.debug_start_msg(msg)
      debug_msg("#{msg}...".ljust(30))
    end

    def self.debug_finish_msg(time_in_ms)
      " (#{time_in_ms} ms)"
    end

    def self.bench(start_msg, &block)
      if !Assert.config.debug
        block.call; return
      end
      print debug_start_msg(start_msg)
      RoundedMillisecondTime.new(Benchmark.measure(&block).real).tap do |time_in_ms|
        puts debug_finish_msg(time_in_ms)
      end
    end

    def initialize(*args)
      @args = args
      @cli = CLIRB.new do
        option "runner_seed", "use a given seed to run tests",
               abbrev: "s", value: Integer
        option "changed_only", "only run test files with changes",
               abbrev: "c"
        option "changed_ref", "reference for changes, use with `-c` opt",
               abbrev: "r", value: ""
        option "single_test", "only run the test on the given file/line",
               abbrev: "t", value: ""
        option "pp_objects", "pretty-print objects in fail messages",
               abbrev: "p"
        option "capture_output", "capture stdout and display in result details",
               abbrev: "o"
        option "halt_on_fail", "halt a test when it fails",
               abbrev: "h"
        option "profile", "output test profile info",
               abbrev: "e"
        option "verbose", "output verbose runtime test info",
               abbrev: "v"
        option "list", "list test files on $stdout",
               abbrev: "l"

        # show loaded test files, cli err backtraces, etc
        option "debug", "run in debug mode", abbrev: "d"
      end
    end

    def run
      begin
        @cli.parse!(@args)
        catch(:halt) do
          Assert::AssertRunner.new(Assert.config, @cli.args, @cli.opts).run
        end
      rescue CLIRB::HelpExit
        puts help
      rescue CLIRB::VersionExit
        puts Assert::VERSION
      rescue CLIRB::Error => exception
        puts "#{exception.message}\n\n"
        puts  Assert.config.debug ? exception.backtrace.join("\n") : help
        exit(1)
      rescue StandardError => exception
        puts "#{exception.class}: #{exception.message}"
        puts exception.backtrace.join("\n")
        exit(1)
      end
      exit(0)
    end

    def help
      "Usage: assert [options] [TESTS]\n\n"\
      "Options:"\
      "#{@cli}"
    end
  end

  module RoundedMillisecondTime
    ROUND_PRECISION = 3
    ROUND_MODIFIER = 10 ** ROUND_PRECISION
    def self.new(time_in_seconds)
      (time_in_seconds * 1000 * ROUND_MODIFIER).to_i / ROUND_MODIFIER.to_f
    end
  end

  class CLIRB  # Version 1.1.0, https://github.com/redding/cli.rb
    Error    = Class.new(RuntimeError);
    HelpExit = Class.new(RuntimeError); VersionExit = Class.new(RuntimeError)
    attr_reader :argv, :args, :opts, :data

    def initialize(&block)
      @options = []; instance_eval(&block) if block
      require "optparse"
      @data, @args, @opts = [], [], {}; @parser = OptionParser.new do |p|
        p.banner = ""; @options.each do |o|
          @opts[o.name] = o.value; p.on(*o.parser_args){ |v| @opts[o.name] = v }
        end
        p.on_tail("--version", ""){ |v| raise VersionExit, v.to_s }
        p.on_tail("--help",    ""){ |v| raise HelpExit,    v.to_s }
      end
    end

    def option(*args); @options << Option.new(*args); end
    def parse!(argv)
      @args = (argv || []).dup.tap do |args_list|
        begin; @parser.parse!(args_list)
        rescue OptionParser::ParseError => err; raise Error, err.message; end
      end; @data = @args + [@opts]
    end
    def to_s; @parser.to_s; end
    def inspect
      "#<#{self.class}:#{"0x0%x" % (object_id << 1)} @data=#{@data.inspect}>"
    end

    class Option
      attr_reader :name, :opt_name, :desc, :abbrev, :value, :klass, :parser_args

      def initialize(name, desc = nil, abbrev: nil, value: nil)
        @name, @desc = name, desc || ""
        @opt_name, @abbrev = parse_name_values(name, abbrev)
        @value, @klass = gvalinfo(value)
        @parser_args = if [TrueClass, FalseClass, NilClass].include?(@klass)
          ["-#{@abbrev}", "--[no-]#{@opt_name}", @desc]
        else
          ["-#{@abbrev}", "--#{@opt_name} VALUE", @klass, @desc]
        end
      end

      private

      def parse_name_values(name, custom_abbrev)
        [ (processed_name = name.to_s.strip.downcase).gsub("_", "-"),
          custom_abbrev || processed_name.gsub(/[^a-z]/, "").chars.first || "a"
        ]
      end
      def gvalinfo(v); v.kind_of?(Class) ? [nil,v] : [v,v.class]; end
    end
  end
end
