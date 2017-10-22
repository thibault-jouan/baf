Feature: Error reporting

  Scenario: reports error name and description
    Given the following baf program:
      """
      Class.new Baf::CLI do
        def run
          fail 'some error'
        end
      end.run ARGV
      """
    When I run the program
    Then the output must match /\ARuntimeError: some error\n/

  Scenario: supports custom error handler
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        class << self
          def handle_error env, ex
            env.puts_error "#{ex.class} (#{ex})"
            71
          end
        end

        def run
          fail 'some error'
        end
      end.run(ARGV)
      """
    When I run the program
    Then the error output must contain exactly "RuntimeError (some error)\n"
    And the exit status must be 71
