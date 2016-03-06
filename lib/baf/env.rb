require 'forwardable'

module Baf
  class Env
    extend Forwardable
    def_delegator :@output, :print

    def initialize output
      @output = output
    end
  end
end
