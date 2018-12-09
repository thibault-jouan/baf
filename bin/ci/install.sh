#!/usr/bin/env sh

set -e

echo "source 'https://rubygems.org'; gemspec" > ~/gem.deps.rb
gem install --conservative --minimal-deps --no-lock --file ~/gem.deps.rb
