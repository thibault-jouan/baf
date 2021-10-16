require 'fileutils'

require 'baf'
require 'baf/testing/process'

module Baf
  module Testing
    ExecutionTimeout = Class.new Error

    ENV_WHITELIST = [
      'BAF_TEST_DEBUG',
      /\ACHRUBY_/,
      /\AGEM_/,
      /\ARB_/,
      'RUBYOPT'
    ].freeze

    EXEC_TIMEOUT_ERROR_FMT = 'process did not exit after %.03f seconds'.freeze

    WORKING_DIR = 'tmp/uat'.freeze

    class << self
      def build_regexp pattern, options
        Regexp.new(pattern, options.each_char.inject(0) do |m, e|
          m | case e
            when ?i then Regexp::IGNORECASE
            when ?m then Regexp::MULTILINE
            when ?x then Regexp::EXTENDED
          end
        end)
      end

      def exercise_scenario block, dir: WORKING_DIR
        FileUtils.remove_entry_secure dir, true
        FileUtils.mkdir_p dir
        Dir.chdir dir do
          block.call
        end
      end

      def run command, wait: true, env_allow: [], timeout: nil
        timeout ||= Process::TIMEOUT
        Process.new(command,
          env_allow: ENV_WHITELIST + env_allow,
          timeout: timeout
        ).tap do |exec|
          exec.start
          exec.wait do
            exec.stop
            fail ExecutionTimeout, EXEC_TIMEOUT_ERROR_FMT % timeout
          end if wait
        end
      end

      def unescape_step_arg str
        str.gsub '\n', "\n"
      end

      def write_file path, content
        FileUtils.mkdir_p File.dirname path
        IO.write path, content + $/
      end
    end
  end
end
