Feature: Program usage

  Scenario: reports error and prints the usage when unknown option is given
    Given the following baf program:
      """
      Baf::CLI.run(ARGV)
      """
    When I run the program with option --unkwnown-option
    Then the exit status must be 64
    And the output must contain exactly:
      """
      Usage: baf [options]

      options:
          -h, --help                       print this message
      """

  Scenario: prints the usage when -h option is given
    Given the following baf program:
      """
      Baf::CLI.run(ARGV)
      """
    When I successfully run the program with option -h
    Then the output must contain exactly:
      """
      Usage: baf [options]

      options:
          -h, --help                       print this message
      """

  Scenario: prevents running the program when -h option is given
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        def run
          fail
        end
      end.run(ARGV)
      """
    When I run the program with option -h
    Then the exit status must be 0

  Scenario: separates user-defined options and default options with an empty line
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        def setup
          flag_verbose
        end
      end.run(ARGV)
      """
    When I successfully run the program with option -h
    Then the output must contain exactly:
      """
      Usage: baf [options]

      options:
          -v, --verbose                    enable verbose mode

          -h, --help                       print this message
      """

  Scenario: supports setting a custom usage banner
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        def setup
          banner 'my_program [options] arguments...'
        end
      end.run(ARGV)
      """
    When I successfully run the program with option -h
    Then the output must contain:
      """
      my_program [options] arguments...
      """
