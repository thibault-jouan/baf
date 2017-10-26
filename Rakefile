require 'cucumber/rake/task'
require 'rspec/core/rake_task'

task default: %i[features spec]

Cucumber::Rake::Task.new :features do |t|
  t.profile = 'quiet' if ENV.key? 'BAFTEST_CI'
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = '--format progress' if ENV.key? 'BAFTEST_CI'
end
