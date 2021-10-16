Feature: User acceptance testing framework and test utilities

  Scenario: saves the exit status code
    Given the following baf program:
      """
      exit 70
      """
    When I run the program
    Then the exit status must be 70

  Scenario: changes current dir to the test directory
    Given the following baf program:
      """
      puts Dir.pwd
      """
    When I successfully run the program
    Then the output must contain exactly the test directory

  Scenario: cleans up the test directory before each test
    Given a file named features/support/env.rb with:
      """
      require 'baf/testing/cucumber'
      """
    Given a file named features/clean_test_dir.feature with:
      """
      Feature: Stub scenarios
        Scenario: lists current dir children and create an observable artefact
          Given a file named script.rb with:
            \"\"\"
            require 'fileutils'
            Dir.children(?.).each { puts _1 }
            FileUtils.touch 'test_artefact_to_be_cleaned'
            \"\"\"
          When I run `ruby script.rb`
          Then the exit status must be 0
          And the output must contain exactly "script.rb\n"
      """
    When I successfully run `cucumber`
    And I run `cucumber`
    Then the exit status must be 0

  Scenario: aborts waiting when process does not exit after the timeout
    Given a file named features/support/env.rb with:
      """
      require 'baf/testing/cucumber'
      $_baf[:exec_timeout] = 0.001
      """
    And a file named features/run_timeout_abort.feature with:
      """
      Feature: Stub scenarios
        Scenario: runs a program for longer than the configured timeout
          When I run `sleep 2`
          Then the exit status must be 0
      """
    When I run `cucumber`
    Then the exit status must be 1
    And the output must contain "process did not exit after 0.001 seconds"

  Scenario: terminates the process when it does not exit after the timeout
    Given a file named features/support/env.rb with:
      """
      require 'baf/testing/cucumber'
      $_baf[:exec_timeout] = 0.001
      """
    And a file named features/run_timeout_term.feature with:
      """
      Feature: Stub scenarios
        Scenario: runs a program for longer than the configured timeout
          Given a file named script.rb with:
            \"\"\"
            Process.setproctitle 'baf_test_run_timeout_term'
            sleep 2
            \"\"\"
          When I run `ruby script.rb`
          Then the exit status must be 0
      """
    When I run `cucumber`
    Then the exit status must be 1
    And the output must contain "process did not exit after 0.001 seconds"
    And no running process matches /baf_test_run_timeout_term/

  Scenario: kills the process when it does not terminate before the timeout

  Scenario: passes the given arguments to the program
    Given the following baf program:
      """
      puts ARGV.join ', '
      """
    When I successfully run the program with arguments foo bar
    Then the output must contain "foo, bar"

  Scenario: passes the given options to the program (conveniance for args)
    Given the following baf program:
      """
      puts ARGV
      """
    When I successfully run the program with options -vd
    Then the output must contain "-vd"

  Scenario: restricts the environment
    Given the following baf program:
      """
      puts ENV.keys
      """
    When I successfully run the program
    Then the output must not contain "LANG"
    And the output must not contain "SHELL"

  Scenario: mocks the home directory
    Given the following baf program:
      """
      puts ENV['HOME']
      """
    When I successfully run the program
    Then the output must contain exactly the test directory

  Scenario: saves the standard error stream
    Given the following baf program:
      """
      $stderr.puts 'err'
      """
    When I successfully run the program
    Then the error output must contain exactly "err\n"

  Scenario: writes to the standard input stream
    Given the following baf program:
      """
      $stdout.puts $stdin.gets.chomp
      """
    When I start the program
    And I input "testing the input\n"
    Then the output will contain "testing the input"
