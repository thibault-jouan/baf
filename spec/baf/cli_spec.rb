module Baf
  RSpec.describe CLI do
    include ExitHelpers

    let(:stdout)        { StringIO.new }
    let(:stderr)        { StringIO.new }
    let(:env)           { Env.new(stdout) }
    let(:arguments)     { %w[foo bar] }
    let(:config)        { described_class.config }
    let(:dsl)           { Class.new(described_class) }
    subject(:cli)       { described_class.new env, arguments, config }

    describe '.flag' do
      it 'configures the given flag' do
        dsl.flag :f, :foo
        expect(dsl.config[:flags])
          .to include an_object_having_attributes short: :f, long: :foo
      end
    end

    describe '.flag_verbose' do
      it 'configures a verbose flag' do
        dsl.flag_verbose
        expect(dsl.config[:flags])
          .to include an_object_having_attributes short: :v, long: 'verbose'
      end
    end

    describe '.option' do
      it 'configures the given option' do
        dsl.option :f, :foo, 'VALUE', 'set foo to VALUE'
        expect(dsl.config[:options]).to include an_object_having_attributes(
          short:  :f,
          long:   :foo,
          arg:    'VALUE',
          desc:   'set foo to VALUE'
        )
      end
    end

    describe '.run' do
      subject(:run) { described_class.run arguments, stderr: stderr }

      it 'builds a new CLI' do
        expect(described_class).to receive(:new).and_call_original
        trap_exit! { run }
      end

      it 'parses CLI arguments' do
        cli
        allow(described_class).to receive(:new) { cli }
        expect(cli).to receive :parse_arguments!
        run
      end

      it 'runs the CLI' do
        cli
        allow(described_class).to receive(:new) { cli }
        expect(cli).to receive :run
        run
      end

      context 'when given invalid arguments' do
        let(:arguments) { %w[--unknown-option] }

        it 'prints the usage on standard error stream' do
          trap_exit { run }
          expect(stderr.string).to start_with 'Usage: '
        end

        it 'exits with a return status of 64' do
          expect { run }.to raise_error(SystemExit) do |e|
            expect(e.status).to eq 64
          end
        end
      end

      context 'when the CLI raises an error' do
        before do
          allow(cli).to receive(:run) { fail 'some error' }
          allow(described_class).to receive(:new) { cli }
        end

        it 'exits with a return status of 70' do
          expect { run }.to raise_error(SystemExit) do |e|
            expect(e.status).to eq 70
          end
        end

        it 'prints the error on error output' do
          trap_exit { run }
          expect(stderr.string).to start_with 'RuntimeError: some error'
        end
      end
    end

    describe '#initialize' do
      let(:option_parser) { OptionParser.new }
      let(:registrant)    { OptionsRegistrant }
      let(:config)        { { parser: option_parser, registrant: registrant } }

      it 'registers given config with the specified registrant' do
        expect(registrant).to receive(:register).with(
          env, option_parser, config
        )
        cli
      end
    end

    describe '#arguments' do
      it 'returns given arguments' do
        expect(cli.arguments).to eq arguments
      end
    end

    describe '#env' do
      it 'returns given env' do
        expect(cli.env).to eq env
      end
    end

    describe '#parse_arguments!' do
      let(:option_parser) { OptionParser.new }

      before { config[:parser] = option_parser }

      it 'asks the option parser to parse CLI arguments' do
        expect(option_parser).to receive(:parse!).with arguments
        cli.parse_arguments!
      end

      context 'when given an invalid option' do
        let(:arguments) { %w[--unknown-option] }

        it 'raises a CLI::ArgumentError' do
          expect { cli.parse_arguments! }
            .to raise_error CLI::ArgumentError
        end
      end
    end
  end
end
