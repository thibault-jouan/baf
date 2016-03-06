Feature: Built-in debug option flag declaration

  Scenario: supports built-in debug option flag
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        flag_debug

        def run
          puts env.debug?
        end
      end.run(ARGV)
      """
    When I run the program with option -d
    Then the output must contain exactly "true\n"
