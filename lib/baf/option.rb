module Baf
  class Option
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
      message = tail? ? :on_tail : :on
      mblock  = block ? -> * { block[env] } : parser_argument_block(env)
      [message, "-#{short}", parser_argument_long, parser_argument_desc, mblock]
    end

  protected

    def build_attrs short, long, arg_or_desc = nil, desc_or_block = nil
      {
        short:  short,
        long:   long
      }.merge case desc_or_block
      when Proc
        {
          desc:   arg_or_desc,
          block:  desc_or_block
        }
      when String
        {
          arg:  arg_or_desc,
          desc: desc_or_block
        }
      else
        {}
      end
    end

    def parser_argument_long
      [
        '--' + long.to_s.tr(?_, ?-),
        arg
      ].compact.join ' '
    end

    def parser_argument_desc
      desc
    end

    def parser_argument_block env
      -> v { env.send :"#{long}=", v }
    end
  end
end
