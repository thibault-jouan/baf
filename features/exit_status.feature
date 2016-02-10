Feature: Exit status

  Scenario: returns a status of 0
    Given the following baf program:
      """
      Baf::CLI.run(ARGV)
      """
    When I run the program
    Then the exit status must be 0

  Scenario: returns a status of 70 on errors
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        def run
          fail
        end
      end.run(ARGV)
      """
    When I run the program
    Then the exit status must be 70
