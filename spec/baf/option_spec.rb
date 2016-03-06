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
    end
  end
end
