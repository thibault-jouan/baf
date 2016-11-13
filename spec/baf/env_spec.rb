require 'baf/env'

module Baf
  RSpec.describe Env do
    let(:input)   { StringIO.new }
    let(:output)  { StringIO.new }
    subject(:env) { described_class.new input: input, output: output }

    describe '#gets' do
      it 'reads the next line from the input' do
        input.puts 'some input'
        input.rewind
        expect(env.gets).to eq 'some input' + $/
      end
    end

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
