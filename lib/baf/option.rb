module Baf
  class Option
    LONG_PREFIX             = '--'.freeze
    LONG_NORMALIZE_SEARCH   = ?_.freeze
    LONG_NORMALIZE_REPLACE  = ?-.freeze
    LONG_WITH_ARG_GLUE      = ' '.freeze
    PARSER_MESSAGE          = :on
    PARSER_MESSAGE_TAIL     = :on_tail

    attr_accessor :short, :long, :arg, :desc, :block, :tail

    def initialize *args, tail: false
      attrs = args.size > 1 ? build_attrs(*args) : args[0]
      attrs.each { |k, v| send :"#{k}=", v }
      self.tail = tail
    end

    def env_definition
      :accessor
    end

    def block?
      !!block
    end

    def tail?
      !!tail
    end

    def to_parser_arguments env
      message = tail? ? PARSER_MESSAGE_TAIL : PARSER_MESSAGE
      mblock = if block?
        -> *args { block[*args, env] }
      else
        parser_argument_block env
      end
      [message, "-#{short}", parser_argument_long, parser_argument_desc, mblock]
    end

  private

    def build_attrs short, long, arg_or_desc = nil, desc_or_block = nil, block = nil
      {
        short:  short,
        long:   long,
        desc:   arg_or_desc
      }.merge case desc_or_block
      when Proc
        {
          desc:   arg_or_desc,
          block:  desc_or_block
        }
      when String
        {
          arg:    arg_or_desc,
          desc:   desc_or_block,
          block:  block
        }
      else
        {}
      end
    end

    def parser_argument_long
      [
        LONG_PREFIX + long
          .to_s
          .tr(LONG_NORMALIZE_SEARCH, LONG_NORMALIZE_REPLACE),
        arg
      ].compact.join LONG_WITH_ARG_GLUE
    end

    def parser_argument_desc
      desc
    end

    def parser_argument_block env
      -> v { env.send :"#{long}=", v }
    end
  end
end
