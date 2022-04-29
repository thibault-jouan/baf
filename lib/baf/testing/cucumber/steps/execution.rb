def run state, cmd: nil, wait: true, args: []
  cmd ||= state[:program]
  Baf::Testing.run cmd + args,
    wait: wait,
    env_allow: state.fetch(:env_allow) { [] },
    timeout: state[:exec_timeout]
end


When /^I( successfully)? (run|\w+) the program$/ do |check, run|
  $_baf[:process] = run $_baf, wait: run == 'run'
  Baf::Testing.expect_ex $_baf[:process], 0 if check
end

When(
  /^I( successfully)? (run|\w+) the program with (?:argument|command|option)s? (.+)$/
) do |check, run, args|
  $_baf[:process] = run $_baf, wait: run == 'run', args: args.split(' ')
  Baf::Testing.expect_ex $_baf[:process], 0 if check
end

When /^I( successfully)? (run|\w+) `([^`]+)`$/ do |check, run, command|
  $_baf[:process] = run $_baf, cmd: command.split(' '), wait: run == 'run'
  Baf::Testing.expect_ex $_baf[:process], 0 if check
end


Then /^the program must terminate successfully$/ do
  Baf::Testing.wait $_baf[:process]
  Baf::Testing.expect_ex $_baf[:process], 0
end

Then /^the exit status must be (\d+)$/ do |exit_status|
  Baf::Testing.expect_ex $_baf[:process], Integer(exit_status)
end
