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

    def build_attrs(short, long, arg_or_block = nil, desc = nil)
      {
        short:  short,
        long:   long,
        desc:   desc
      }.tap do |attrs|
        case arg_or_block
          when Proc   then attrs[:block]  = arg_or_block
          when String then attrs[:arg]    = arg_or_block
        end
      end
    end

    def parser_argument_long
      [
        '--' + long.to_s.tr(?_, ?-),
        arg
      ].join ' '
    end
  end
end
