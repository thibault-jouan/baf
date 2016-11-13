require 'baf/env'

module Baf
  RSpec.describe Env do
    let(:output)  { StringIO.new }
    subject(:env) { described_class.new output }

    describe '#print' do
      it 'prints given argument to the output' do
        env.print 'something'
        expect(output.string).to eq 'something'
      end
    end

    describe '#puts' do
      it 'prints given arg to the output with input record separator suffix' do
        env.puts 'something'
        expect(output.string).to eq 'something' + $/
      end
    end
  end
end
