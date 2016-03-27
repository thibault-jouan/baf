require 'baf/flag'
require 'baf/option'

module Baf
  class OptionsRegistrant
    SUMMARY_HEADER = "\noptions:".freeze

    def initialize env, parser, options = []
      @env      = env
      @parser   = parser
      @options  = options
    end

    def flag *args, **opts
      options << Flag.new(*args, **opts)
    end

    def option *args
      options << Option.new(*args)
    end

    def register
      yield if block_given?
      parser.separator SUMMARY_HEADER
      options.each do |opt|
        send :"define_env_#{opt.env_definition}", env, opt.long unless opt.block?
        *args, block = opt.to_parser_arguments env
        parser.send *args, &block
      end
      register_default_options
    end

  private

    attr_reader :env, :parser, :options

    def define_env_accessor env, name
      (class << env; self end).send :attr_accessor, name
    end

    def define_env_predicate env, name
      define_env_accessor env, name
      env.send :"#{name}=", false
      env.define_singleton_method :"#{name}?" do
        instance_variable_get :"@#{name}"
      end
      env.instance_variable_set :"@#{name}", false
    end

    def register_default_options
      parser.separator '' if options.any?
      parser.on_tail '-h', '--help', 'print this message' do
        env.print parser
      end
    end
  end
end
