require 'timeout'

module Baf
  module Testing
    class WaitError < ::StandardError
      attr_reader :timeout

      def initialize message, timeout
        super message
        @timeout = timeout
      end
    end
  end
end

def wait_output! content
  output = -> { last_command_started.output }
  wait_until do
    output.call.include? content
  end
rescue Baf::Testing::WaitError => e
  fail <<-eoh
expected `#{content}' not seen after #{e.timeout} seconds in:
  ```\n#{output.call.lines.map { |l| "  #{l}" }.join}  ```
  eoh
end

def wait_until message: 'condition not met after %d seconds'
  timeout = 2
  Timeout.timeout(timeout) do
    loop do
      break if yield
      sleep 0.05
    end
  end
rescue Timeout::Error
  raise Baf::Testing::WaitError.new(message % timeout, timeout)
end


Then /^the output will contain "([^"]+)"$/ do |content|
  wait_output! content
end
