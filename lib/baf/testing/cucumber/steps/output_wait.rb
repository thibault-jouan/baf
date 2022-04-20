def wait_output pattern, output: -> { $_baf[:process].output }, times: 1
  Baf::Testing.wait_output pattern, stream: output, times: times
end


Then /^the output will match \/([^\/]+)\/([a-z]*)$/ do |pattern, options|
  wait_output Baf::Testing.build_regexp pattern, options
end

Then /^the output will contain:$/ do |content|
  wait_output content + $/
end

Then /^the output will contain "([^"]+)"$/ do |content|
  wait_output content
end
