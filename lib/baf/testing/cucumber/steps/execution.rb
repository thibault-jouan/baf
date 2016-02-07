def program_run check: false, opts: nil, args: nil
  cmd = %w[ruby baf]
  cmd << opts if opts
  cmd << args.split(' ') if args
  run_simple cmd.join(' '), fail_on_error: false
  return unless check
  expect(last_command_started).to have_exit_status 0
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
  expect(last_command_started).to have_exit_status exit_status.to_i
end
