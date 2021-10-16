require 'pathname'

Then /^no running process matches \/([^\/]+)\/([a-z]*)$/ do |pattern, options|
  processes = `ps -o command`.lines.map &:chomp
  expect(processes.grep Baf::Testing.build_regexp(pattern, options)).to be_empty
end

Then /^the output must contain exactly the test directory$/ do
  expect($_baf[:process].output.chomp)
    .to eq (Pathname(__dir__).parent.parent + 'tmp/uat').to_s
end
