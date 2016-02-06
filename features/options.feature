Feature: Options declaration

  declares simple option flag with `.option' class method

  Background:
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        option :v, :verbose

        def run!
          puts env.verbose?
        end
      end.run(ARGV)
      """

  Scenario: returns false when env is sent option message for disabled option
    When I run the program
    Then the output must contain exactly "false\n"

  Scenario: returns false when env is sent option message for enabled option
    When I run the program with option -v
    Then the output must contain exactly "true\n"
