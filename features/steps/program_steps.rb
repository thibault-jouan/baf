Given /^the following baf program:$/ do |program|
  write_file 'baf', <<-eoh
#!/usr/bin/env ruby
require 'baf/cli'

#{program}
  eoh
  chmod '0700', 'baf'
end
