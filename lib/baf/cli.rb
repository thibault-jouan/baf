module Baf
  class CLI
    EX_SOFTWARE = 70

    class << self
      def option short, long, registrant: OptionRegistrant
        registrant.register(env, option_parser, short, long)
      end

      def run arguments, stderr: $stderr
        cli = new env, option_parser, arguments
        cli.parse_arguments!
        cli.run!
      rescue StandardError => e
        stderr.puts "#{e.class.name}: #{e.message}"
        stderr.puts e.backtrace.map { |l| '  %s' % l }
        exit EX_SOFTWARE
      end

    private

      def env
        @env ||= Env.new
      end

      def option_parser
        @option_parser ||= OptionParser.new
      end
    end

    attr_reader :arguments, :env, :option_parser

    def initialize env, option_parser, arguments
      @env            = env
      @option_parser  = option_parser
      @arguments      = arguments
    end

    def parse_arguments!
      option_parser.parse! arguments
    end

    def run!
    end
  end
end
