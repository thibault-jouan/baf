require 'baf/option'

module Baf
  class Flag < Option
    DESCRIPTION_FORMAT = 'enable %s mode'.freeze

    def env_definition
      :predicate
    end

  protected

    def parser_argument_desc
      if desc then super else DESCRIPTION_FORMAT % long end
    end

    def parser_argument_block env
      -> * { env.send :"#{long}=", true }
    end
  end
end
