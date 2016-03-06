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

    CONFIG_DEFAULTS = {
      flags:      [],
      options:    [],
      parser:     OptionParser.new,
      registrant: OptionsRegistrant
    }.freeze

    class << self
      def config
        @config ||= CONFIG_DEFAULTS.dup
      end

      def flag *args
        config[:flags] << Option.new(*args)
      end

      def flag_verbose
        config[:flags] << Option.new(:v, 'verbose')
      end

      def flag_debug
        config[:flags] << Option.new(:d, 'debug')
      end

      def option *args
        config[:options] << Option.new(*args)
      end

      def run arguments, stdout: $stdout, stderr: $stderr
        cli = new Env.new(stdout), arguments, config
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

    attr_reader :arguments, :env, :option_parser

    def initialize env, arguments, config
      @env            = env
      @option_parser  = config[:parser]
      @arguments      = arguments

      config[:registrant].register env, config[:parser], config
    end

    def parse_arguments!
      option_parser.parse! arguments
    rescue OptionParser::InvalidOption
      raise ArgumentError, option_parser
    end

    def run
    end
  end
end
