Gem::Specification.new do |s|
  s.name = 'baf'
  s.version = '0.14.1'.freeze
  s.summary = 'Toolkit for testing and writing CLI programs'.freeze
  s.description = <<~eoh.freeze
    baf helps writing an user acceptance test suite with a dedicated library
    and cucumber steps. It can run and wait for programs in a modified
    environment, verify the exit status, the output streams and other side
    effects. It also supports interactive programs and writing to their
    standard input.

    Then, it provides a DSL to write the CLI:

        require 'baf/cli'

        module MyProgram
          class CLI < Baf::CLI
            def setup
              flag_version '0.1.2'.freeze

              option :c, :config, 'config', 'specify config file' do |path|
                @config_path = path
              end
            end

            def run
              usage! unless arguments.any?

              puts 'arguments: %s' % arguments
              puts 'config: %s' % @config_path if @config_path
            end
          end
        end

        MyProgram::CLI.run ARGV

    Which behaves this way:

        % ./my_program
        Usage: my_program [options]

        options:
            -c, --config config              specify config file

            -h, --help                       print this message
            -V, --version                    print version
        zsh: exit 64    ./my_program

        % ./my_program --wrong-arg
        Usage: my_program [options]

        options:
            -c, --config config              specify config file

            -h, --help                       print this message
            -V, --version                    print version
        zsh: exit 64    ./my_program --wrong-arg

        % ./my_program foo
        arguments ["foo"]

        % ./my_program -c some_file foo
        arguments ["foo"]
        config path some_file
  eoh
  s.license = 'BSD-3-Clause'
  s.homepage = 'https://rubygems.org/gems/baf'

  s.authors = 'Thibault Jouan'
  s.email = 'tj@a13.fr'

  s.files = Dir['lib/**/*']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'cucumber', '~> 3.2'
  s.add_development_dependency 'rspec', '~> 3.11'
end
