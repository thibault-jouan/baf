Feature: Built-in version option flag declaration

  Scenario: supports built-in version option flag
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        def setup
          flag_version '0.13.42'
        end
      end.run(ARGV)
      """
    When I successfully run the program with option -V
    Then the output must contain exactly "0.13.42\n"
