module Baf
  RSpec.describe Env do
    let(:output)  { StringIO.new }
    subject(:env) { Env.new output }

    describe '#print' do
      it 'prints the message to the output' do
        env.print 'something'
        expect(output.string).to eq 'something'
      end
    end
  end
end
