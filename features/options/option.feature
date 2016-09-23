Feature: Option declaration

  Scenario: supports option with argument
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        def setup
          option :f, :foo, 'VALUE', 'set foo to VALUE'
        end

        def run
          puts env.foo
        end
      end.run(ARGV)
      """
    When I successfully run the program with option -f bar
    Then the output must contain exactly "bar\n"

  Scenario: calls the given block with option value and env
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        def setup
          option :f, :foo, 'VALUE', 'do something' do |foo, env|
            env.puts "do something with #{foo}"
          end
        end
      end.run(ARGV)
      """
    When I successfully run the program with option -f bar
    Then the output must contain exactly "do something with bar\n"

  Scenario: converts `_' to `-' in long options
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        def setup
          option :f, :foo_option, 'VALUE', 'set foo to VALUE'
        end

        def run
          puts env.foo_option
        end
      end.run(ARGV)
      """
    When I successfully run the program with option --foo-option bar
    Then the output must contain exactly "bar\n"

  Scenario: describes the option in usage options summary
    Given the following baf program:
      """
      Class.new(Baf::CLI) do
        def setup
          option :f, :foo, 'VALUE', 'set foo to VALUE'
        end
      end.run(ARGV)
      """
    When I successfully run the program with option -h
    Then the output must match /-f.+--foo.+set foo to VALUE/
