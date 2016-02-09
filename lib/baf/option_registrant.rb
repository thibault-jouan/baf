module Baf
  class OptionRegistrant
    class << self
      def register_flag env, parser, short, long
        define_env_flag env, long
        parser.on "-#{short}", "--#{long}", "enable #{long} mode" do
          env.send :"#{long}=", true
        end
      end

      def register_option env, parser, opt
        define_env_accessor env, opt.long
        parser.on "-#{opt.short}", "--#{opt.long} #{opt.arg}", opt.desc do |v|
          env.send :"#{opt.long}=", v
        end
      end

    protected

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
end
