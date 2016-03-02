def program_run check: false, opts: nil, args: nil
  cmd = [*@_baf_program ||= %w[ruby baf]]
  cmd << opts if opts
  cmd << args.split(' ') if args
  run_simple cmd.join(' '), fail_on_error: false
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


When /^I( successfully)? run the program$/ do |check|
  program_run check: !!check
end

When /^I( successfully)? run the program with arguments (.+)$/ do |check, args|
  program_run check: !!check, args: args
end

When /^I( successfully)? run the program with options? (-.+)$/ do |check, opts|
  program_run check: !!check, opts: opts
end


Then /^the exit status must be (\d+)$/ do |exit_status|
  program_run_check status: exit_status.to_i
end

Then /^the program must terminate successfully$/ do
  program_run_check status: 0
end
