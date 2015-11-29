module Baf
  class CLI
    EX_SOFTWARE = 70

    class << self
      def run arguments, stderr: $stderr
        new(arguments).run!
      rescue StandardError => e
        stderr.puts "#{e.class.name}: #{e.message}"
        stderr.puts e.backtrace.map { |l| '  %s' % l }
        exit EX_SOFTWARE
      end
    end

    attr_reader :arguments

    def initialize arguments
      @arguments = arguments
    end

    def run!
    end
  end
end
