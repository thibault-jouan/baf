#!/usr/bin/env sh

set -e

export RUBYOPT="-I$(realpath lib)"
rake
