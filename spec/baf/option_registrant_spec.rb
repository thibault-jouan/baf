module Baf
  RSpec.describe OptionRegistrant do
    let(:env)     { Env.new }
    let(:parser)  { OptionParser.new }

    describe '.register' do
      subject(:register) { described_class.register env, parser, :v, :verbose }

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
  end
end
