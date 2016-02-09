Feature: Options declaration

  Scenario: declares simple option flag with `.option' class method
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        option :f, :foo
        option :b, :bar

        def run!
          puts env.foo?
          puts env.bar?
        end
      end.run(ARGV)
      """
    When I run the program with option -f
    Then the output must contain exactly "true\nfalse\n"
