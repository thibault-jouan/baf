require 'aruba/platforms/unix_platform'

module Aruba
  module Platforms
    class UnixPlatform
      def chmod(mode, args, options)
        FileUtils.chmod_R(mode, args, **options)
      end

      def rm(paths, options = {})
        paths = Array(paths).map { |p| ::File.expand_path(p) }

        FileUtils.rm_r(paths, **options)
      end
    end
  end
end
