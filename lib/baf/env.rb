require 'forwardable'

module Baf
  class Env
    extend Forwardable
    def_delegators :@input, :gets
    def_delegators :@output, :print, :puts
    def_delegator :@output_error, :puts, :puts_error

    def initialize input: $stdin, output: $stdout, output_error: $stderr
      @input        = input
      @output       = output
      @output_error = output_error
    end

    def sync_output
      output.sync = true
    end

  private

    attr_reader :output
  end
end
