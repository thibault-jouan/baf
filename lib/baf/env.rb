require 'forwardable'

module Baf
  class Env
    extend Forwardable
    def_delegators :@input, :gets
    def_delegators :@output, :print, :puts

    def initialize input: $input, output: $stdout
      @input  = input
      @output = output
    end
  end
end
