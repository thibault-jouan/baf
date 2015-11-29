module Baf
  class CLI
    EX_SOFTWARE = 70

    class << self
      def run _, stderr: $stderr
        new.run!
      rescue StandardError => e
        stderr.puts "#{e.class.name}: #{e.message}"
        stderr.puts e.backtrace.map { |l| '  %s' % l }
        exit EX_SOFTWARE
      end
    end

    def run!
    end
  end
end
