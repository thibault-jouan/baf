module Baf
  RSpec.describe OptionRegistrant do
    let(:output)  { StringIO.new }
    let(:env)     { Env.new(output) }
    let(:parser)  { OptionParser.new }

    describe '.register_flag' do
      subject(:register) do
        described_class.register_flag env, parser, :v, :verbose
      end

      it 'defines an env accessor named after long option' do
        register
        env.verbose = :foo
        expect(env.verbose).to eq :foo
      end

      it 'defines a predicate methods named after long option' do
        register
        env.verbose = true
        expect(env).to be_verbose
      end

      it 'adds an option handler to the parser' do
        register
        parser.parse! %w[-v]
        expect(env).to be_verbose
      end
    end

    describe '.register_option' do
      let :opt do
        double 'option',
          short:  :f,
          long:   :foo,
          arg:    'VALUE',
          desc:   'set foo to VALUE'
      end
      subject :register do
        described_class.register_option env, parser, opt
      end

      it 'defines an env accessor named after long option' do
        register
        env.foo = :bar
        expect(env.foo).to eq :bar
      end

      it 'adds an option handler to the parser' do
        register
        parser.parse! %w[-f bar]
        expect(env.foo).to eq 'bar'
      end
    end
  end
end
