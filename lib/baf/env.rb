require 'forwardable'

module Baf
  class Env
    extend Forwardable
    def_delegators :@output, :print, :puts

    def initialize output
      @output = output
    end
  end
end
