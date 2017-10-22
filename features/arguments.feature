Feature: Program arguments

  Scenario: returns program arguments when `arguments' message is sent
    Given the following baf program:
      """
      Class.new Baf::CLI do
        def run
          puts arguments
        end
      end.run ARGV
      """
    When I successfully run the program with arguments foo bar
    Then the output must contain exactly "foo\nbar\n"
