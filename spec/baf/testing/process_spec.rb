require 'baf/testing/process'

RSpec.describe Baf::Testing::Process do
  include ProcessHelpers

  let :command do
    %w[
      ruby
      --disable-gems
      -e $stdout.puts\ 'standard';$stderr.puts\ 'error'
    ]
  end
  subject(:process) { described_class.new command }

  it { is_expected.to have_attributes pid: nil, exit_status: nil, timeout: 4 }

  describe '#start' do
    it 'starts the program and sets its pid' do
      process.start
      expect(process.pid).to be > 0
      expect(process_running? process.pid).to be true
    end

    it 'restricts the environment' do
      command.replace %w[sh -c export]
      process.start
      process.wait
      expect(process.output.lines.map { _1.chomp })
        .not_to include *%w[LANG PATH SHELL USER]
    end

    it 'keeps allowed variable in the environment' do
      process = described_class.new %w[sh -c export], env_allow: %w[USER]
      process.start
      process.wait
      expect(process.output.lines.map { _1.chomp })
        .to include 'USER'
    end

    it 'mocks the home directory as the current working directory' do
      process = described_class.new %w[sh -c echo\ $HOME]
      process.start
      process.wait
      expect(process.output.chomp).to eq File.realpath ?.
    end

    it 'raises an error when execution fails' do
      process = described_class.new %w[non_existent]
      expect { process.start }
        .to raise_error Baf::Testing::Process::ExecutionFailure
    end
  end

  describe '#wait' do
    let(:command) { %w[sh -c exit\ 70] }

    it 'waits for the program to terminate and sets the exit status code' do
      process.start
      process.wait
      expect(process.exit_status).to eq 70
    end

    it 'yields the given block when the timeout is reached' do
      process = described_class.new %w[sleep 1], timeout: 0.001
      process.start
      expect { process.wait { throw :timeout } }.to throw_symbol :timeout
    end
  end

  describe '#stop' do
    let :command do
      ['ruby', '-e', <<~eoh]
        $stdout.sync = true
        trap :TERM do
          puts 'received TERM signal'
          exit 70 if ARGV[0] == 'EXIT_ON_TERM'
        end
        puts 'trapped TERM signal'
        sleep 8
        exit 42
      eoh
    end

    it 'sends the TERM signal' do
      command << 'EXIT_ON_TERM'
      process.start
      sleep 0.01 until process.output.include? 'trapped TERM signal'
      process.stop
      expect(process.exit_status).to eq 70
      expect(process.output).to end_with "received TERM signal\n"
    end

    it 'sends the KILL signal when the process lives after receiving TERM' do
      process.start
      sleep 0.01 until process.output.include? 'trapped TERM signal'
      process.stop wait_timeout: 0.01
      expect(process_running? process.pid).to be false
      expect(process.output).to eq <<~eoh
        trapped TERM signal
        received TERM signal
      eoh
    end

    it 'handles a race when the process exits before second signal or wait' do
      process = described_class.new %w[true]
      process.start
      expect { process.stop wait_timeout: 0.001 }.not_to raise_error
    end
  end

  describe '#running?' do
    it 'returns false when the process has not been started' do
      expect(process.running?).to be false
    end

    it 'returns true when the process is running' do
      process = described_class.new %w[sleep 1]
      process.start
      expect(process.running?).to be true
    ensure
      process.stop
    end

    it 'returns false after the process has exited' do
      process.start
      process.wait
      expect(process.running?).to be false
    end
  end

  describe '#input' do
    let(:command) { %w[ruby -e puts\ $stdin.gets.chomp.reverse] }

    it 'writes to the program standard input stream' do
      process.start
      process.input "foo\n"
      process.wait
      expect(process.output).to eq "oof\n"
    end
  end

  describe '#output' do
    it 'returns the combined output streams' do
      process.start
      process.wait
      expect(process.output).to eq "standard\nerror\n"
    end

    it 'returns the standard output stream when given :output' do
      process.start
      process.wait
      expect(process.output :output).to eq "standard\n"
    end

    it 'returns the standard error stream when given :error' do
      process.start
      process.wait
      expect(process.output :error).to eq "error\n"
    end
  end
end
