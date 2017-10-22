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
