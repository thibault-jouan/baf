def program_run
  cmd = %w[ruby baf]
  run_simple cmd.join(' '), fail_on_error: false
end


When /^I run the program$/ do
  program_run
end


Then /^the exit status must be (\d+)$/ do |exit_status|
  expect(last_command_started).to have_exit_status exit_status.to_i
end
