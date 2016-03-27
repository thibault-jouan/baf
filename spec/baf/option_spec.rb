require 'baf/option'

module Baf
  RSpec.describe Option do
    let(:short)       { :f }
    let(:long)        { 'foo' }
    let(:arg)         { 'VALUE' }
    let(:desc)        { 'set foo to VALUE' }
    subject(:option)  { described_class.new short, long, arg, desc }

    describe '#initialize' do
      it 'assigns given arguments' do
        expect(option).to have_attributes(
          short:  :f,
          long:   'foo',
          arg:    'VALUE',
          desc:   'set foo to VALUE'
        )
      end

      context 'when given short and long' do
        subject(:option) { described_class.new short, long }

        it { is_expected.to have_attributes short: :f, long: 'foo' }
      end

      context 'when given short, long, arg and desc' do
        it do
          is_expected.to have_attributes short: :f, long: 'foo',
            arg: 'VALUE', desc: 'set foo to VALUE'
        end
      end

      context 'when given short, long, desc and block' do
        subject :option do
          described_class.new short, long, desc, -> { :some_block }
        end

        it do
          is_expected.to have_attributes short: :f, long: 'foo',
            desc: 'set foo to VALUE'
        end

        it 'assigns the block' do
          expect(option.block.call).to eq :some_block
        end
      end

      context 'when given flag option' do
        subject(:option) { described_class.new short, long, flag: true }

        it { is_expected.to be_flag }
      end

      context 'when given tail option' do
        subject(:option) { described_class.new short, long, tail: true }

        it { is_expected.to be_tail }
      end
    end

    describe '#flag?' do
      it 'returns false when option is not a flag' do
        expect(option.flag?).to be false
      end

      it 'returns true when option is a flag' do
        option.flag = true
        expect(option.flag?).to be true
      end
    end

    describe '#tail?' do
      it 'returns false when option is not at tail' do
        expect(option.tail?).to be false
      end

      it 'returns true when option is at tail' do
        option.tail = true
        expect(option.tail?).to be true
      end
    end

    describe '#to_parser_arguments' do
      it 'returns suitable arguments for an OptionParser option' do
        expect(option.to_parser_arguments).to match [
          a_string_including(?f),
          a_string_including('foo'),
          a_string_including('foo')
        ]
      end

      it 'prepends `-\' to the short option' do
        expect(option.to_parser_arguments[0]).to eq '-f'
      end

      it 'prepends `--\' to the long option' do
        expect(option.to_parser_arguments[1]).to start_with '--foo'
      end

      it 'appends the long option argument after a space' do
        expect(option.to_parser_arguments[1]).to end_with 'foo VALUE'
      end

      it 'converts `_\' to `-\' in long option' do
        option.long = :foo_option
        expect(option.to_parser_arguments[1]).to match /foo-option/
      end

      it 'does not append a trailing space when arg is nil' do
        option.arg = nil
        expect(option.to_parser_arguments[1]).to end_with 'foo'
      end
    end
  end
end
