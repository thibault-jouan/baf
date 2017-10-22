Feature: Built-in debug option flag declaration

  Scenario: supports built-in debug option flag
    Given the following baf program:
      """
      Class.new Baf::CLI do
        def setup
          flag_debug
        end

        def run
          puts env.debug?
        end
      end.run ARGV
      """
    When I successfully run the program with option -d
    Then the output must contain exactly "true\n"

  Scenario: describes the flag in usage options summary
    Given the following baf program:
      """
      Class.new Baf::CLI do
        def setup
          flag_debug
        end
      end.run ARGV
      """
    When I successfully run the program with option -h
    Then the output must match /-d.+--debug.+enable debug mode/
