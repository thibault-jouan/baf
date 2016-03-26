require 'baf/env'
require 'baf/option'
require 'baf/options_registrant'

module Baf
  RSpec.describe OptionsRegistrant do
    let(:env)             { Env.new(StringIO.new) }
    let(:parser)          { OptionParser.new }
    subject(:registrant)  { OptionsRegistrant.new env, parser }

    describe '#register_default_options' do
      before { registrant.register_default_options }

      it 'adds a header for options on the parser' do
        expect(parser.to_s).to match /\n^options:\n\s+-/
      end

      it 'adds help option on option parser tail' do
        expect(parser.to_s).to match /^\s+-h,\s+--help\s+print this message\n/
      end
    end

    describe '#flag' do
      before { registrant.flag :v, :verbose }

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

      context 'when given a block' do
        let(:block) { proc { throw :option_block } }

        before { registrant.flag :f, :foo, 'foo description', block }

        it 'does not define the predicate method' do
          expect(env).not_to respond_to :foo?
        end

        it 'adds an option handler with given block to the parser' do
          expect { parser.parse! %w[-f bar] }
            .to throw_symbol :option_block
        end
      end

      context 'when given tail option' do
        before { registrant.flag :f, :foo, tail: true }

        it 'appends the option on tail' do
          registrant.flag :b, :bar
          expect(parser.help).to match /bar.+foo/m
        end
      end
    end

    describe '#option' do
      before { registrant.option :f, :foo, 'VALUE', 'set foo to VALUE' }

      it 'defines an env accessor named after long option' do
        env.foo = :bar
        expect(env.foo).to eq :bar
      end

      it 'adds an option handler to the parser' do
        parser.parse! %w[-f bar]
        expect(env.foo).to eq 'bar'
      end
    end
  end
end
