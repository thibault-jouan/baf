module Baf
  class CLI
    EX_SOFTWARE = 70

    class << self
      def run _
        new.run!
      rescue StandardError => e
        exit EX_SOFTWARE
      end
    end

    def run!
    end
  end
end
