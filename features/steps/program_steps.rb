Given /^the following baf program:$/ do |program|
  write_file 'baf', <<-eoh
#!/usr/bin/env ruby
require 'baf'

#{program}
  eoh
  chmod '0700', 'baf'
end
