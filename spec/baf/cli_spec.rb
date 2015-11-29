module Baf
  RSpec.describe CLI do
    subject(:cli) { described_class.new }

    describe '.run' do
      subject(:run) { described_class.run [] }

      it 'builds a new CLI' do
        expect(described_class).to receive(:new).and_call_original
        run
      end

      it 'runs the CLI' do
        cli
        allow(described_class).to receive(:new) { cli }
        expect(cli).to receive :run!
        run
      end

      context 'when the CLI raises an error' do
        before do
          allow(cli).to receive(:run!) { fail 'some error' }
          allow(described_class).to receive(:new) { cli }
        end

        it 'exits with a return status of 70' do
          expect { run }.to raise_error(SystemExit) do |e|
            expect(e.status).to eq 70
          end
        end
      end
    end
  end
end
