Feature: Built-in verbose option flag declaration

  Scenario: supports built-in verbose option flag
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        def setup
          flag_verbose
        end

        def run
          puts env.verbose?
        end
      end.run(ARGV)
      """
    When I successfully run the program with option -v
    Then the output must contain exactly "true\n"

  Scenario: describes the flag in usage options summary
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        def setup
          flag_verbose
        end
      end.run(ARGV)
      """
    When I successfully run the program with option -h
    Then the output must match /-v.+--verbose.+enable verbose mode/
