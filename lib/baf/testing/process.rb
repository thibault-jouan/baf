require 'baf'

require 'tempfile'

module Baf
  module Testing
    class Process
      ExecutionFailure = Class.new Error

      TIMEOUT = 4
      TMP_FILE_PREFIX = 'baf_test_'.freeze
      WAIT_POLL_DELAY = 0.01

      attr_reader :pid, :exit_status

      def initialize command, env_allow: [], timeout: TIMEOUT
        @command = command
        @env_allow = env_allow
        @timeout = timeout
        @stdout = Tempfile.new TMP_FILE_PREFIX
        @stderr = Tempfile.new TMP_FILE_PREFIX
      end

      def start
        reader, writer = IO.pipe

        @pid = spawn env,
          *@command,
          unsetenv_others: true,
          in: reader,
          out: @stdout,
          err: @stderr
        reader.close
        @stdin = writer
      rescue Errno::ENOENT => e
        fail ExecutionFailure, e.message
      end

      def wait timeout: @timeout
        deadline = Time.now + timeout
        wait_poll
        until stopped? || Time.now >= deadline
          sleep WAIT_POLL_DELAY
          wait_poll
        end
        yield unless stopped? if block_given?
      end

      def stop wait_timeout: 1
        ::Process.kill :TERM, @pid
        wait timeout: wait_timeout
        return if stopped?
        ::Process.kill :KILL, @pid
        ::Process.wait2 @pid
      rescue Errno::ECHILD, Errno::ESRCH
      end

      def input str
        @stdin.write str
      end

      def output stream = nil
        case stream
          when :output then [@stdout]
          when :error then [@stderr]
          else [@stdout, @stderr]
        end.inject '' do |memo, stream|
          memo + IO.read(stream.path)
        end
      end

    private

      def env
        ENV.inject({}) do |acc, (k, v)|
          if env_allow? k then acc.merge k => v else acc end
        end.merge 'HOME' => File.realpath(?.)
      end

      def env_allow? var
        @env_allow.any? do |e|
          case e
            when String then var == e
            when Regexp then var =~ e
          end
        end
      end

      def stopped?
        !!@exit_status
      end

      def wait_poll
        pid, status = ::Process.wait2 @pid, ::Process::WNOHANG
        @exit_status = status.exitstatus if pid
      end
    end
  end
end
