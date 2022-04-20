require 'fileutils'

require 'baf/testing'

RSpec.describe Baf::Testing do
  describe '.exercise_scenario' do
    let(:dir) { 'tmp/integration/test' }

    around do |example|
      parent = File.dirname dir
      FileUtils.remove_entry_secure parent, true
      example.run
      FileUtils.remove_entry_secure parent, true
    end

    it 'changes the current working directory to the given path' do
      actual_dir = nil
      described_class.exercise_scenario(dir: dir) { actual_dir = Dir.pwd }
      expect(actual_dir).to eq File.realpath dir
    end

    it 'calls the block with a clean directory' do
      FileUtils.mkdir_p dir
      FileUtils.touch "#{dir}/foo"
      entries = []
      described_class.exercise_scenario(dir:dir) { entries = Dir.entries ?. }
      expect(entries).to eq %w[. ..]
    end
  end

  describe '.expect_ex' do
    let(:process) { double 'process', exit_status: 70, output: "foo\nbar\n" }

    it 'raises an error when given a non matching exit status' do
      expect { described_class.expect_ex process, 0 }
        .to raise_error Baf::Testing::ExitStatusMismatch
    end

    it 'adds the expected and actual exit status to the exception message' do
      expect { described_class.expect_ex process, 0 }
        .to raise_error /expected 0.+got 70/
    end

    it 'adds the process output to the exception message' do
      expect { described_class.expect_ex process, 0 }.to raise_error do |ex|
        expect(ex.message).to include process.output
      end
    end
  end

  describe '.run' do
    it 'executes the given command and returns a "process"' do
      process = described_class.run %w[sh -c exit\ 70]
      expect(process.exit_status).to eq 70
    end

    it 'mocks the home directory' do
      process = described_class.run %w[sh -c echo\ $HOME]
      expect(process.output.chomp).to eq File.realpath ?.
    end

    it 'whitelists some environment variables' do
      key = 'BAF_TEST_STUB_WHITELIST'.freeze
      begin
        ENV[key] = 'yes'
        process = described_class.run %W[sh -c echo\ $#{key}], env_allow: [key]
      ensure
        ENV.delete key
      end
      expect(process.output.chomp).to eq 'yes'
    end

    it 'raises an error when the execution takes too much time' do
      expect { described_class.run %w[sh -c sleep\ 1], timeout: 0.001 }
        .to raise_error Baf::Testing::ExecutionTimeout
    end
  end

  describe '.unescape_step_arg' do
    it 'replaces "\n" strings by a newline character (LF)' do
      expect(described_class.unescape_step_arg 'foo\nbar\n').to eq "foo\nbar\n"
    end
  end
end
