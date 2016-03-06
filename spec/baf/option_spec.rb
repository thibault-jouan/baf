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
  end
end
