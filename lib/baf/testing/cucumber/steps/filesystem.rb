Given /^a file named ([^ ]+) with:$/ do |path, content|
  Baf::Testing.write_file path, content
end
