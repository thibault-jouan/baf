module Baf
  class Option
    attr_accessor :short, :long, :arg, :desc, :block

    def initialize *args
      attrs = args.size > 1 ? build_attrs(*args) : args[0]
      attrs.each { |k, v| send :"#{k}=", v }
    end

    def to_parser_arguments
      ["-#{short}", parser_argument_long, desc]
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
  end
end
