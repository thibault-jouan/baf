require 'fileutils'

Given /^the following baf program:$/ do |program|
  IO.write 'baf', <<-eoh
#!/usr/bin/env ruby
require 'baf/cli'

#{program}
  eoh
  FileUtils.chmod 0700, 'baf'
  $_baf[:program] = %w[ruby baf].freeze
end
