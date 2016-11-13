When /^I input "([^"]+)"$/ do |content|
  last_command_started.write unescape_text content
end
