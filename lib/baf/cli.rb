require 'optparse'

require 'baf'
require 'baf/env'
require 'baf/option'
require 'baf/options_registrant'

module Baf
  class CLI
    ArgumentError = Class.new(::Baf::ArgumentError)

    EX_USAGE    = 64
    EX_SOFTWARE = 70

    class << self
      def run arguments, stdout: $stdout, stderr: $stderr
        cli = new Env.new(stdout), arguments
        cli.parse_arguments!
        cli.run
      rescue ArgumentError => e
        stderr.puts e
        exit EX_USAGE
      rescue StandardError => e
        stderr.puts "#{e.class.name}: #{e}"
        stderr.puts e.backtrace.map { |l| '  %s' % l }
        exit EX_SOFTWARE
      end
    end

    attr_reader :arguments, :env, :parser

    def initialize env, arguments, **opts
      @env        = env
      @arguments  = arguments
      @parser     = opts[:parser]     || OptionParser.new
      @registrant = opts[:registrant] || OptionsRegistrant.new(env, parser)

      registrant.register_default_options
      setup
    end

    def setup
    end

    def flag *args
      registrant.flag *args
    end

    def flag_debug
      flag :d, 'debug'
    end

    def flag_verbose
      flag :v, 'verbose'
    end

    def flag_version version
      flag :V, 'version', -> env { env.puts version }
    end

    def option *args
      registrant.option *args
    end

    def parse_arguments!
      parser.parse! arguments
    rescue OptionParser::InvalidOption
      raise ArgumentError, parser
    end

    def run
    end

  private

    attr_reader :registrant
  end
end
