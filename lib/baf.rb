require 'optparse'

require 'baf/cli'
require 'baf/env'
require 'baf/option_registrant'

module Baf
  Error         = Class.new(::StandardError)
  ArgumentError = Class.new(Error)
end
