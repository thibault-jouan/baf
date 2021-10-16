When /^I input "([^"]+)"$/ do |content|
  $_baf[:process].input Baf::Testing.unescape_step_arg content
end
