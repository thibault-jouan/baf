def program_run check: false, opts: nil, args: nil, wait: true
  cmd = [*@_baf_program ||= %w[ruby baf]]
  cmd << opts if opts
  cmd << args.split(' ') if args
  if wait
    run_simple cmd.join(' '), fail_on_error: false
  else
    run cmd.join ' '
  end
  program_run_check if check
end

def program_run_check status: 0
  expect(last_command_started).to have_exit_status status
rescue RSpec::Expectations::ExpectationNotMetError => e
  if ENV.key? 'BAF_TEST_DEBUG'
    fail RSpec::Expectations::ExpectationNotMetError, <<-eoh
#{e.message} Output was:
  ```\n#{last_command_started.output.lines.map { |l| "  #{l}" }.join}  ```
    eoh
  else
    raise
  end
end


When /^I( successfully)? (run|\w+) the program$/ do |check, run|
  program_run check: !!check, wait: run == 'run'
end

When /^I( successfully)? (run|\w+) the program with arguments (.+)$/ do |check, run, args|
  program_run check: !!check, args: args, wait: run == 'run'
end

When /^I( successfully)? (run|\w+) the program with options? (-.+)$/ do |check, run, opts|
  program_run check: !!check, opts: opts, wait: run == 'run'
end


Then /^the exit status must be (\d+)$/ do |exit_status|
  program_run_check status: exit_status.to_i
end

Then /^the program must terminate successfully$/ do
  program_run_check status: 0
end
