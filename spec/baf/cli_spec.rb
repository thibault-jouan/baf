module Baf
  RSpec.describe CLI do
    include ExitHelpers

    let(:stdout)        { StringIO.new }
    let(:stderr)        { StringIO.new }
    let(:env)           { Env.new(stdout) }
    let(:option_parser) { OptionParser.new }
    let(:arguments)     { %w[foo bar] }
    subject(:cli)       { described_class.new env, option_parser, arguments }

    describe '.flag' do
      it 'registers given option flag with an option registrant' do
        registrant = double 'registrant'
        expect(registrant).to receive(:register_flag).with(
          an_instance_of(Env),
          an_instance_of(OptionParser),
          :short,
          :long
        )
        described_class.flag :short, :long, registrant: registrant
      end
    end

    describe '.option' do
      it 'registers given option with an option registrant' do
        registrant = double 'registrant'
        expect(registrant).to receive :register_option do |env, parser, opt|
          expect(env).to be_an Env
          expect(parser).to be_an OptionParser
          expect(opt.short).to eq :f
          expect(opt.long).to eq :foo
          expect(opt.arg).to eq 'VALUE'
          expect(opt.desc).to eq 'set foo to VALUE'
        end
        described_class
          .option :f, :foo, 'VALUE', 'set foo to VALUE', registrant: registrant
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
      it 'adds a header for options on option parser' do
        cli
        expect(option_parser.to_s).to match /\n^options:\n\s+-/
      end

      it 'adds help option on option parser tail' do
        cli
        expect(option_parser.to_s).to match /^\s+-h,\s+--help\s+print this message\n/
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
