module Baf
  Option = Struct.new('Option', :short, :long, :arg, :desc) do
    def to_parser_arguments
      ["-#{short}", parser_argument_long, desc]
    end

  protected

    def parser_argument_long
      [
        '--' + long.to_s.tr(?_, ?-),
        arg
      ].join ' '
    end
  end
end
