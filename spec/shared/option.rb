RSpec.shared_examples 'option' do
  let(:short)       { :f }
  let(:long)        { :foo }
  let(:arg)         { 'VALUE' }
  let(:desc)        { 'set foo to VALUE' }
  subject(:option)  { described_class.new short, long, arg, desc }

  describe '#initialize' do
    it 'assigns given arguments' do
      expect(option).to have_attributes(
        short:  :f,
        long:   :foo,
        arg:    'VALUE',
        desc:   'set foo to VALUE'
      )
    end

    context 'when given short and long' do
      subject(:option) { described_class.new short, long }

      it { is_expected.to have_attributes short: :f, long: :foo }
    end

    context 'when given short, long, arg and desc' do
      it do
        is_expected.to have_attributes short: :f, long: :foo,
          arg: 'VALUE', desc: 'set foo to VALUE'
      end
    end

    context 'when given short, long, desc and block' do
      subject :option do
        described_class.new short, long, desc, -> { :some_block }
      end

      it do
        is_expected.to have_attributes short: :f, long: :foo,
          desc: 'set foo to VALUE'
      end

      it 'assigns the block' do
        expect(option.block.call).to eq :some_block
      end
    end

    context 'when given tail option' do
      subject { described_class.new short, long, tail: true }

      it { is_expected.to be_tail }
    end
  end

  describe '#block?' do
    it 'returns false when no block is assigned' do
      subject.block = nil
      expect(option.block?).to be false
    end

    it 'returns true when a block is assigned' do
      subject.block = -> {}
      expect(option.block?).to be true
    end
  end

  describe '#tail?' do
    it 'returns false when option is not at tail' do
      expect(option.tail?).to be false
    end

    it 'returns true when option is at tail' do
      subject.tail = true
      expect(option.tail?).to be true
    end
  end

  describe '#to_parser_arguments' do
    let(:env) { double 'env' }

    it 'returns suitable arguments for an OptionParser option' do
      expect(option.to_parser_arguments env).to match [
        :on,
        a_string_including(?f),
        a_string_including('foo'),
        a_string_including('foo'),
        kind_of(Proc)
      ]
    end

    it 'returns `on_tail\' message when option is on tail' do
      subject.tail = true
      expect(option.to_parser_arguments(env)[0]).to eq :on_tail
    end

    it 'prepends `-\' to the short option' do
      expect(option.to_parser_arguments(env)[1]).to eq '-f'
    end

    it 'prepends `--\' to the long option' do
      expect(option.to_parser_arguments(env)[2]).to start_with '--foo'
    end

    it 'appends the long option argument after a space' do
      expect(option.to_parser_arguments(env)[2]).to end_with 'foo VALUE'
    end

    it 'converts `_\' to `-\' in long option' do
      subject.long = :foo_option
      expect(option.to_parser_arguments(env)[2]).to include 'foo-option'
    end

    it 'does not append a trailing space to long option when arg is nil' do
      subject.arg = nil
      expect(option.to_parser_arguments(env)[2]).to end_with 'foo'
    end

    it 'returns the assigned description' do
      expect(option.to_parser_arguments(env)[3]).to eq 'set foo to VALUE'
    end
  end
end
