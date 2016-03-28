require 'baf/flag'
require 'baf/option'

module Baf
  class OptionsRegistrant
    SUMMARY_HEADER    = "\noptions:".freeze
    HELP_PARSER_ARGS  = %w[
      -h
      --help
      print\ this\ message
    ].freeze.each &:freeze

    def initialize options = []
      @options = options
    end

    def flag *args, **opts
      options << Flag.new(*args, **opts)
    end

    def option *args
      options << Option.new(*args)
    end

    def register env, parser
      yield if block_given?
      parser.separator SUMMARY_HEADER
      options.each do |opt|
        send :"define_env_#{opt.env_definition}", env, opt.long unless opt.block?
        *args, block = opt.to_parser_arguments env
        parser.send *args, &block
      end
      register_default_options env, parser
    end

  private

    attr_reader :options

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

    def register_default_options env, parser
      parser.separator '' if options.any?
      parser.on_tail *HELP_PARSER_ARGS do
        env.print parser
      end
    end
  end
end
