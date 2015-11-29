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

  s.files       = `git ls-files lib`.split $/

  s.add_development_dependency 'aruba',     '~> 0.11', '< 0.12'
  s.add_development_dependency 'cucumber',  '~> 2.0'
  s.add_development_dependency 'rake',      '~> 10.4'
  s.add_development_dependency 'rspec',     '~> 3.4'
end
