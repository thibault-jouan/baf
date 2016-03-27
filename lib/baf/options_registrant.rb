module Baf
  class OptionsRegistrant
    def initialize env, parser
      @env      = env
      @parser   = parser
      @options  = []
    end

    def register
      yield
      options.each do |opt|
        define_env_accessor env, opt.long
        parser.on *opt.to_parser_arguments do |v|
          env.send :"#{opt.long}=", v
        end
      end
      register_default_options
    end

    def register_default_options
      parser.separator ''
      parser.separator 'options:'
      parser.on_tail '-h', '--help', 'print this message' do
        env.print parser
      end
    end

    def flag *args, tail: false
      opt = Option.new(*args)
      position = tail ? :on_tail : :on
      if opt.block
        parser.send position, *opt.to_parser_arguments do
          opt.block[env]
        end
      else
        define_env_flag env, opt.long
        parser.send position,
            "-#{opt.short}", "--#{opt.long}", "enable #{opt.long} mode" do
          env.send :"#{opt.long}=", true
        end
      end
    end

    def option *args
      options << Option.new(*args)
    end

  protected

    attr_reader :env, :parser, :options

    def define_env_accessor env, name
      (class << env; self end).send :attr_accessor, name
    end

    def define_env_flag env, name
      define_env_accessor env, name
      env.send :"#{name}=", false
      env.define_singleton_method :"#{name}?" do
        instance_variable_get :"@#{name}"
      end
      env.instance_variable_set :"@#{name}", false
    end
  end
end
