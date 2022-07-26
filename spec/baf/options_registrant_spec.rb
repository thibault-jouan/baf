require 'optparse'

require 'baf/env'
require 'baf/options_registrant'

module Baf
  RSpec.describe OptionsRegistrant do
    include ExitHelpers

    let(:options) { [] }
    subject(:registrant) { described_class.new options }

    describe '#flag' do
      it 'adds a new option flag' do
        aggregate_failures 'option flag' do
          expect { registrant.flag :v, :verbose }
            .to change { options.size }
            .by 1
          expect(options).to include a_kind_of Flag
        end
      end
    end

    describe '#option' do
      it 'adds a new option' do
        expect { registrant.option :f, :foo, 'VALUE', 'set foo to VALUE' }
          .to change { options.size }
          .by 1
      end
    end

    describe '#register' do
      let(:output) { StringIO.new }
      let(:env) { Env.new output: output }
      let(:parser) { OptionParser.new }

      it 'sets the assigned usage banner' do
        registrant.banner = 'Usage: my_program arguments...'
        registrant.register env, parser
        expect(parser.to_s).to match /\AUsage: my_program arguments\.\.\.\n/
      end

      it 'adds a header for options on the parser' do
        registrant.register env, parser
        expect(parser.to_s).to match /\n^options:\n\s+-/
      end

      it 'yields the given block' do
        expect { |b| registrant.register env, parser, &b }
          .to yield_control
      end

      context 'when a flag is declared' do
        before do
          registrant.flag :v, :verbose
          registrant.register env, parser
        end

        it 'defines an env accessor named after long option' do
          env.verbose = :foo
          expect(env.verbose).to eq :foo
        end

        it 'defines a predicate method named after long option' do
          env.verbose = true
          expect(env).to be_verbose
        end

        it 'adds an option handler to the parser' do
          parser.parse! %w[-v]
          expect(env).to be_verbose
        end
      end

      context 'when a flag with a block is declared' do
        let(:block) { proc { throw :option_block } }

        before do
          registrant.flag :f, :foo, 'foo description', block
          registrant.register env, parser
        end

        it 'does not define the predicate method' do
          expect(env).not_to respond_to :foo?
        end

        it 'adds an option handler with given block to the parser' do
          expect { parser.parse! %w[-f bar] }
            .to throw_symbol :option_block
        end
      end

      context 'when a flag is declared at tail' do
        before { registrant.flag :f, :foo, tail: true }

        it 'appends the option on tail' do
          registrant.flag :b, :bar
          registrant.register env, parser
          expect(parser.help).to match /bar.+foo/m
        end

        it 'registers the option after default ones' do
          registrant.register env, parser
          expect(parser.help).to match /help.+foo/m
        end
      end

      context 'when an option is declared' do
        before do
          registrant.option :f, :foo, 'VALUE', 'set foo to VALUE'
          registrant.register env, parser
        end

        it 'defines an env accessor named after long option' do
          env.foo = :bar
          expect(env.foo).to eq :bar
        end

        it 'adds an option handler to the parser' do
          parser.parse! %w[-f bar]
          expect(env.foo).to eq 'bar'
        end
      end

      context 'built-in help' do
        it 'adds help option on option parser tail' do
          registrant.register env, parser
          expect(parser.to_s)
            .to match /^\s+-h,\s+--help\s+print this message\n/
        end

        it 'adds an help option handler printing usage on env output' do
          registrant.register env, parser
          trap_exit { parser.parse! %w[-h] }
          expect(output.string).to start_with 'Usage: '
        end

        it 'exits with a return status of 0' do
          registrant.register env, parser
          expect { parser.parse! %w[-h] }.to raise_error SystemExit do |e|
            expect(e.status).to eq 0
          end
        end
      end
    end
  end
end
