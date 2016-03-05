require 'forwardable'
require 'optparse'

require 'baf/cli'
require 'baf/env'
require 'baf/options_registrant'

module Baf
  Error         = Class.new(::StandardError)
  ArgumentError = Class.new(Error)
end
