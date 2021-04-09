require File.expand_path('../lib/baf/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'baf'
  s.version     = Baf::VERSION.dup
  s.summary     = 'Basic Application Framework'
  s.description = 'Basic Application Framework'
  s.license     = 'BSD-3-Clause'
  s.homepage    = 'https://rubygems.org/gems/baf'

  s.authors     = 'Thibault Jouan'
  s.email       = 'tj@a13.fr'

  s.files       = Dir['lib/**/*']

  s.add_development_dependency 'baf-testing', '~> 0'
  s.add_development_dependency 'rake'
end
