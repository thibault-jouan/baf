def expect_ex process, exit_status
  expect(process.exit_status).to eq exit_status.to_i
rescue RSpec::Expectations::ExpectationNotMetError => e
  if ENV.key? 'BAF_TEST_DEBUG'
    fail RSpec::Expectations::ExpectationNotMetError, <<-eoh
#{e.message} Output was:
#{?- * 70}
\n#{process.output.lines.map { |l| "  #{l}" }.join}#{?- * 70}
    eoh
  else raise
  end
end

def run state, cmd: nil, wait: true, args: []
  cmd ||= $_baf[:program]
  Baf::Testing.run cmd + args, wait: wait, timeout: $_baf[:exec_timeout]
end


When /^I( successfully)? (run|\w+) the program$/ do |check, run|
  $_baf[:process] = run $_baf, wait: run == 'run'
  expect_ex $_baf[:process], 0 if check
end

When(
  /^I( successfully)? (run|\w+) the program with (?:argument|command|option)s? (.+)$/
) do |check, run, args|
  $_baf[:process] = run $_baf, wait: run == 'run', args: args.split(' ')
  expect_ex $_baf[:process], 0 if check
end

When /^I( successfully)? (run|\w+) `([^`]+)`$/ do |check, run, command|
  $_baf[:process] = run $_baf, cmd: command.split(' '), wait: run == 'run'
  expect_ex $_baf[:process], 0 if check
end


Then /^the program must terminate successfully$/ do
  expect_ex $_baf[:process], 0
end

Then /^the exit status must be (\d+)$/ do |exit_status|
  expect_ex $_baf[:process], exit_status
end
