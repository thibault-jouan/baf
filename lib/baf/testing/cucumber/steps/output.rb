def build_regexp pattern, options
  Regexp.new(pattern, options.each_char.inject(0) do |m, e|
    m | case e
      when ?i then Regexp::IGNORECASE
      when ?m then Regexp::MULTILINE
      when ?x then Regexp::EXTENDED
    end
  end)
end

def expect_output content, stream: :output
  stream = :stderr if stream == :error
  expect(last_command_started.send stream).to eq unescape_text content
end


Then /^the output must contain "([^"]+)"$/ do |content|
  expect(last_command_started.output).to include unescape_text content
end

Then /^the output must not contain "([^"]+)"$/ do |content|
  expect(last_command_started.output).not_to include unescape_text content
end

Then /^the output must contain exactly:$/ do |content|
  expect_output content + $/
end

Then /^the( error)? output must contain exactly "([^"]+)"$/ do |stream, content|
  stream = stream ? :error : :output
  expect_output content, stream: stream
end

Then /^the output must match \/([^\/]+)\/([a-z]*)$/ do |pattern, options|
  expect(last_command_started.output).to match build_regexp(pattern, options)
end
