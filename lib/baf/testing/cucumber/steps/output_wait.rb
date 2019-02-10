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

def wait_output! pattern, times: 1, results: nil
  output = -> { last_command_started.output }
  wait_until do
    case pattern
    when Regexp then (results = output.call.scan(pattern)).size >= times
    when String then output.call.include? pattern
    end
  end
  results
rescue Baf::Testing::WaitError => e
  fail <<-eoh
expected `#{pattern}' not seen after #{e.timeout} seconds in:
  ```\n#{output.call.lines.map { |l| "  #{l}" }.join}  ```
  eoh
end

def wait_until message: 'condition not met after %d seconds'
  timeout = ENV.key?('BAF_TEST_TIMEOUT') ?
    ENV['BAF_TEST_TIMEOUT'].to_i :
    2
  Timeout.timeout timeout do
    loop do
      break if yield
      sleep 0.05
    end
  end
rescue Timeout::Error
  fail Baf::Testing::WaitError.new(message % timeout, timeout)
end


Then /^the output will match \/([^\/]+)\/([a-z]*)$/ do |pattern, options|
  wait_output! build_regexp pattern, options
end

Then /^the output will contain:$/ do |content|
  wait_output! content + $/
end

Then /^the output will contain "([^"]+)"$/ do |content|
  wait_output! content
end
