require 'baf/option'
require 'shared/option'

module Baf
  RSpec.describe Option do
    let(:short) { :f }
    let(:long) { :foo }
    let(:arg) { 'VALUE' }
    let(:desc) { 'set foo to VALUE' }
    subject(:option) { described_class.new short, long, arg, desc }

    include_examples 'option'

    describe '#env_definition' do
      specify { expect(option.env_definition).to eq :accessor }
    end

    describe '#to_parser_arguments' do
      let(:env) { double 'env' }

      context 'when a block is assigned' do
        let(:block) { -> arg { arg } }

        it 'returns a block calling assigned block with the env' do
          option.block = block
          expect(option.to_parser_arguments(env)[4].call).to eq env
        end
      end

      context 'when no block is assigned' do
        it 'returns a block assigning given value to related env accessor' do
          expect(env).to receive(:foo=).with :bar
          option.to_parser_arguments(env)[4].call :bar
        end
      end
    end
  end
end
