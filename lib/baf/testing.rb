require 'fileutils'

require 'baf'
require 'baf/testing/process'

module Baf
  module Testing
    ExecutionTimeout = Class.new Error
    ExitStatusMismatch = Class.new Error

    class WaitError < Error
      attr_reader :timeout

      def initialize message, timeout
        super message
        @timeout = timeout
      end
    end

    ENV_WHITELIST = [
      /\ACHRUBY_/,
      /\AGEM_/,
      'PATH',
      /\ARB_/,
      'RUBYOPT'
    ].freeze

    EXEC_TIMEOUT_ERROR_FMT = 'process did not exit after %.03f seconds'.freeze

    EXIT_STATUS_MISMATCH_FMT = <<~eoh.freeze
      expected %<expected>d exit status got %<actual>d; output was:
      %{separator}
      %{output}
      %{separator}
    eoh

    OUTPUT_SEPARATOR = (?- * 70).freeze

    WAIT_TIMEOUT = ENV.key?('BAF_TEST_TIMEOUT') ?
      ENV['BAF_TEST_TIMEOUT'].to_i :
      2
    WAIT_MESSAGE_FMT = 'condition not met after %.03f seconds'.freeze

    WORKING_DIR = 'tmp/uat'.freeze

    class << self
      def build_regexp pattern, options = ''
        Regexp.new(pattern, options.each_char.inject(0) do |m, e|
          m | case e
            when ?i then Regexp::IGNORECASE
            when ?m then Regexp::MULTILINE
            when ?x then Regexp::EXTENDED
          end
        end)
      end

      def exercise_scenario dir: WORKING_DIR
        FileUtils.remove_entry_secure dir, true
        FileUtils.mkdir_p dir
        Dir.chdir dir do
          yield
        end
      end

      def expect_ex process, exit_status
        return if process.exit_status == exit_status

        fail ExitStatusMismatch, EXIT_STATUS_MISMATCH_FMT % {
          expected: exit_status,
          actual: process.exit_status,
          separator: OUTPUT_SEPARATOR,
          output: process.output.chomp
        }
      end

      def run command, wait: true, env_allow: [], timeout: nil
        Process.new(
          command,
          env_allow: ENV_WHITELIST + env_allow,
          timeout: timeout || Process::TIMEOUT
        ).tap do |process|
          process.start
          wait process if wait
        end
      end

      def wait process
        process.wait do
          process.stop
          fail ExecutionTimeout, EXEC_TIMEOUT_ERROR_FMT % process.timeout
        end
      end

      def unescape_step_arg str
        str.gsub '\n', "\n"
      end

      def wait_until message: WAIT_MESSAGE_FMT, timeout: WAIT_TIMEOUT
        return if yield
        deadline = Time.now + timeout
        until Time.now >= deadline
          return if yield
          sleep 0.05
        end
        fail WaitError.new message % timeout, timeout
      end

      def write_file path, content
        FileUtils.mkdir_p File.dirname path
        IO.write path, content + $/
      end
    end
  end
end
