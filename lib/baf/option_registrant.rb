module Baf
  class OptionRegistrant
    class << self
      def register env, parser, short, long
        Env.class_eval do
          attr_accessor :"#{long}"

          define_method :"#{long}?" do
            !!instance_variable_get(:"@#{long}")
          end
        end
        parser.on "-#{short}", "--#{long}", "enable #{long} mode" do
          env.send :"#{long}=", true
        end
      end
    end
  end
end
