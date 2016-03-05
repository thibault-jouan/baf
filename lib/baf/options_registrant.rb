module Baf
  class OptionsRegistrant
    class << self
      def register *args
        new(*args).register
      end
    end

    def initialize env, parser, config
      @env    = env
      @parser = parser
      @config = config
    end

    def register
      declare_default_options
      config[:flags].each   { |o| flag o.short, o.long }
      config[:options].each { |o| option o }
    end

    def flag short, long
      define_env_flag env, long
      parser.on "-#{short}", "--#{long}", "enable #{long} mode" do
        env.send :"#{long}=", true
      end
    end

    def option opt
      define_env_accessor env, opt.long
      parser.on "-#{opt.short}", "--#{opt.long} #{opt.arg}", opt.desc do |v|
        env.send :"#{opt.long}=", v
      end
    end

  protected

    attr_reader :env, :parser, :config

    def declare_default_options
      parser.separator ''
      parser.separator 'options:'
      parser.on_tail '-h', '--help', 'print this message' do
        env.print parser
      end
    end

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
