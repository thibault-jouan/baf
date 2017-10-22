Feature: Env class customization

  Scenario: uses custom env class if one is defined in CLI parent module
    Given the following baf program:
      """
      module TestEnvCustom
        class Env < Baf::Env
          def initialize output:, **_
            output.puts 'using custom env'
            super
          end
        end

        CLI = Class.new Baf::CLI
      end

      TestEnvCustom::CLI.run ARGV
      """
    When I run the program
    Then the output must contain exactly "using custom env\n"
