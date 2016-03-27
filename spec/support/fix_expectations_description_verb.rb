require 'rspec/expectations'

module RSpec
  module Expectations
    class PositiveExpectationHandler
      class << self
        def verb
          'must'
        end
      end
    end

    class PositiveExpectationHandler
      class << self
        def verb
          'must not'
        end
      end
    end
  end
end
