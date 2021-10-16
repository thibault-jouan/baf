Then /^the output must be empty$/ do
  expect($_baf[:process].output).to be_empty
end

Then /^the output must contain:$/ do |content|
  expect($_baf[:process].output).to include content
end

Then /^the output must contain "([^"]+)"$/ do |content|
  expect($_baf[:process].output).to include content
end

Then /^the output must not contain "([^"]+)"$/ do |content|
  expect($_baf[:process].output).not_to include content
end

Then /^the output must contain exactly:$/ do |content|
  expect($_baf[:process].output).to eq content + $/
end

Then /^the( error)? output must contain exactly "([^"]+)"$/ do |stream, content|
  stream = stream ? :error : :output
  expect($_baf[:process].output stream)
    .to eq Baf::Testing::unescape_step_arg content
end

Then /^the output must match \/([^\/]+)\/([a-z]*)$/ do |pattern, options|
  expect($_baf[:process].output)
    .to match Baf::Testing.build_regexp(pattern, options)
end
