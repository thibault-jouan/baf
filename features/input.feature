Feature: Input stream

  Scenario: provides the program input stream on the env object
    Given the following baf program:
      """
      Class.new Baf::CLI do
        def run
          puts env.gets
        end
      end.run ARGV
      """
    When I start the program
    And I input "testing the input\n"
    Then the output will contain "testing the input"
