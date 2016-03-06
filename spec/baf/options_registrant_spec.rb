require 'baf/env'
require 'baf/option'
require 'baf/options_registrant'

module Baf
  RSpec.describe OptionsRegistrant do
    let(:env)             { Env.new(StringIO.new) }
    let(:parser)          { OptionParser.new }
    let(:config)          { {} }
    subject(:registrant)  { OptionsRegistrant.new env, parser, config }

    describe '#register' do
      let(:flag)    { Option.new(:v, :verbose) }
      let(:option)  { Option.new(:f, :foo, 'VALUE', 'set foo to VALUE') }
      let(:config)  { { flags: [flag], options: [option] } }

      it 'registers flags' do
        registrant.register
        parser.parse! %w[-v]
        expect(env).to be_verbose
      end

      it 'registers options' do
        registrant.register
        parser.parse! %w[-f bar]
        expect(env.foo).to eq 'bar'
      end

      it 'adds a header for options on the parser' do
        registrant.register
        expect(parser.to_s).to match /\n^options:\n\s+-/
      end

      it 'adds help option on option parser tail' do
        registrant.register
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
    end

    describe '#option' do
      let(:option) { Option.new(:f, :foo, 'VALUE', 'set foo to VALUE') }

      before { registrant.option option }

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
