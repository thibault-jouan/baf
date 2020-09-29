require 'optparse'

require 'baf'
require 'baf/env'
require 'baf/flag'
require 'baf/option'
require 'baf/options_registrant'

module Baf
  class CLI
    ArgumentError = Class.new ::Baf::ArgumentError

    EX_USAGE    = 64
    EX_SOFTWARE = 70

    class << self
      def run arguments, stdin: $stdin, stdout: $stdout, stderr: $stderr
        cli = new env = build_env(stdin, stdout, stderr), arguments
        cli.parse_arguments!
        cli.run
      rescue ArgumentError => e
        stderr.puts e
        exit EX_USAGE
      rescue StandardError => e
        if respond_to? :handle_error
          status = handle_error cli.env, e
          exit status if status.respond_to? :to_int
        else
          stderr.puts "#{e.class.name}: #{e}"
          stderr.puts e.backtrace.map { |l| '  %s' % l }
        end
        exit EX_SOFTWARE
      end

    private

      def build_env stdin, stdout, stderr
        env_class.new input: stdin, output: stdout, output_error: stderr
      end

      def env_class
        return Env unless parent_name = name =~ /::[^:]+\Z/ ? $` : nil
        parent = Object.const_get parent_name
        parent.const_defined?(:Env) ? parent.const_get(:Env) : Env
      end

      def ruby2_keywords *; end unless Module.respond_to? :ruby2_keywords, true
    end

    attr_reader :arguments, :env, :parser

    def initialize env, arguments, **opts
      @env        = env
      @arguments  = arguments
      @parser     = opts[:parser]     || OptionParser.new
      @registrant = opts[:registrant] || OptionsRegistrant.new

      registrant.register(env, parser) { setup }
    end

    def setup
    end

    def banner arg
      registrant.banner = arg
    end

    ruby2_keywords \
    def flag *args
      registrant.flag *args
    end

    def flag_debug
      flag :d, :debug
    end

    def flag_verbose
      flag :v, :verbose
    end

    def flag_version version
      flag :V, :version, 'print version', -> *, env { env.puts version; exit },
        tail: true
    end

    def option *args, &block
      args = [*args, block] if block_given?
      registrant.option *args
    end

    def parse_arguments!
      parser.parse! arguments
    rescue OptionParser::InvalidOption
      fail ArgumentError, parser
    end

    def usage!
      fail ArgumentError, parser
    end

    def run
    end

  private

    attr_reader :registrant
  end
end
