require 'baf/cli'

module Baf
  RSpec.describe CLI do
    include ExitHelpers

    let(:stdout)      { StringIO.new }
    let(:stderr)      { StringIO.new }
    let(:env)         { Env.new(stdout) }
    let(:arguments)   { %w[foo bar] }
    let(:parser)      { OptionParser.new }
    let(:registrant)  { OptionsRegistrant.new(env, parser) }
    subject(:cli)     { described_class.new env, arguments }

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
      subject :cli do
        described_class.new env, arguments, registrant: registrant
      end

      it 'tells the registrant to register default options' do
        expect(registrant).to receive :register_default_options
        cli
      end

      it 'sends the :setup message to itself' do
        my_cli_class = Class.new(CLI) do
          define_method(:setup) { throw :my_setup }
        end
        expect { my_cli_class.new env, arguments }.to throw_symbol :my_setup
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

    describe '#flag' do
      subject :cli do
        described_class.new env, arguments, registrant: registrant
      end

      it 'tells the registrant to register given flag' do
        expect(registrant).to receive(:flag).with :f, :foo
        cli.flag :f, :foo
      end
    end

    describe '#flag_debug' do
      subject :cli do
        described_class.new env, arguments, registrant: registrant
      end

      it 'tells the registrant to register -d --debug flag' do
        expect(registrant).to receive(:flag).with :d, 'debug'
        cli.flag_debug
      end
    end

    describe '#flag_verbose' do
      subject :cli do
        described_class.new env, arguments, registrant: registrant
      end

      it 'tells the registrant to register -v --verbose flag' do
        expect(registrant).to receive(:flag).with :v, 'verbose'
        cli.flag_verbose
      end
    end

    describe '#flag_version' do
      subject :cli do
        described_class.new env, arguments, registrant: registrant
      end

      # FIXME: aggregate
      it 'tells the registrant to register a flag printing given version' do
        expect(registrant).to receive(:flag) do |short, long, block|
          expect(short).to eq :V
          expect(long).to eq 'version'
          block.call env
        end
        cli.flag_version '0.13.42'
        expect(stdout.string).to include '0.13.42'
      end
    end

    describe '#option' do
      subject :cli do
        described_class.new env, arguments, registrant: registrant
      end

      it 'tells the registrant to register given option' do
        expect(registrant)
          .to receive(:option)
          .with :f, :foo, 'VALUE', 'set foo to VALUE'
        cli.option :f, :foo, 'VALUE', 'set foo to VALUE'
      end
    end

    describe '#parse_arguments!' do
      subject(:cli) { described_class.new env, arguments, parser: parser }

      it 'asks the option parser to parse CLI arguments' do
        expect(parser).to receive(:parse!).with arguments
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
