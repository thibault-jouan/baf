require 'baf/flag'
require 'shared/option'

module Baf
  RSpec.describe Flag do
    let(:short) { :f }
    let(:long) { :foo }
    subject(:flag) { described_class.new short, long }

    it_behaves_like 'option'

    describe '#env_definition' do
      specify { expect(flag.env_definition).to eq :predicate }
    end

    describe '#to_parser_arguments' do
      let(:env) { double 'env' }

      it 'generates a description when desc is nil' do
        flag.desc = nil
        expect(flag.to_parser_arguments(env)[3]).to eq 'enable foo mode'
      end

      context 'when a block is assigned' do
        let(:block) { -> arg { arg } }

        it 'returns a block calling assigned block with the env' do
          flag.block = block
          expect(flag.to_parser_arguments(env)[4].call).to eq env
        end
      end

      context 'when no block is assigned' do
        it 'returns a block assigning true to related env predicate' do
          expect(env).to receive(:foo=).with true
          flag.to_parser_arguments(env)[4].call :bar
        end
      end
    end
  end
end
