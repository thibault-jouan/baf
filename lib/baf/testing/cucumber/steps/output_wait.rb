def wait_output!(
  pattern, output: -> { $_baf[:process].output }, times: 1, results: nil
)
  Baf::Testing.wait_until do
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


Then /^the output will match \/([^\/]+)\/([a-z]*)$/ do |pattern, options|
  wait_output! Baf::Testing.build_regexp pattern, options
end

Then /^the output will contain:$/ do |content|
  wait_output! content + $/
end

Then /^the output will contain "([^"]+)"$/ do |content|
  wait_output! content
end
