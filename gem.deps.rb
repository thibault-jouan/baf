source 'https://rubygems.org'

gemspec

eval File.read('gem.deps-custom.rb') if File.exist?('gem.deps-custom.rb')
