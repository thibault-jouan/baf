require 'baf/env'

module Baf
  RSpec.describe Env do
    let(:input)         { StringIO.new }
    let(:output)        { StringIO.new }
    let(:output_error)  { StringIO.new }
    subject :env do
      described_class.new \
        input: input,
        output: output,
        output_error: output_error
    end

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

    describe '#puts_error' do
      it 'prints arg to the error output with input record separator suffix' do
        env.puts_error 'something'
        expect(output_error.string).to eq 'something' + $/
      end
    end

    describe '#sync_output' do
      it 'syncs the output' do
        expect(output)
          .to receive(:sync=)
          .with true
        env.sync_output
      end
    end
  end
end
