Feature: Option flag declaration

  Scenario: declares a predicate method on the env object
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
    When I successfully run the program with option -f
    Then the output must contain exactly "true\nfalse\n"

  Scenario: describes the flag in usage options summary
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        def setup
          flag :f, :foo
        end
      end.run(ARGV)
      """
    When I successfully run the program with option -h
    Then the output must match /-f.+--foo.+enable foo mode/

  Scenario: declares a flag with a custom description
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        def setup
          flag :f, :foo, 'use the foo!'
        end
      end.run(ARGV)
      """
    When I successfully run the program with option -h
    Then the output must match /-f.+--foo.+use the foo!/
