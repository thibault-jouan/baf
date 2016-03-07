Feature: Option flag declaration

  Scenario: supports simple option flag
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        def setup
          flag :f, :foo
          flag :b, :bar
        end

        def run
          puts env.foo?
          puts env.bar?
        end
      end.run(ARGV)
      """
    When I run the program with option -f
    Then the output must contain exactly "true\nfalse\n"
