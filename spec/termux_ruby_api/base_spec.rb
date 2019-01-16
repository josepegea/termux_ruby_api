require 'termux_ruby_api/base'
require 'ostruct'

RSpec.describe TermuxRubyApi::Base do

  let (:success) { OpenStruct.new(success?: true) }
  let (:failure) { OpenStruct.new(success?: false) }

  describe "parsing arguments and standard input" do
    it "works with a basic command (successful)" do
      expect(Open3).to receive(:capture3).with('termux-test', stdin_data: '').once.and_return(['', '', success])
      subject.api_command('test')
    end

    it "works with a basic command (unsuccessful)" do
      expect(Open3).to receive(:capture3).with('termux-test', stdin_data: '').once.and_return(['', '', failure])
      expect { subject.api_command('test') }.to raise_error(TermuxRubyApi::CommandError)
    end

    it "works with a command with args (successful)" do
      expect(Open3).to receive(:capture3).with('termux-test', 'x', 'y', stdin_data: '').once.and_return(['', '', success])
      subject.api_command('test', nil, 'x', 'y')
    end

    it "works with a command with args (unsuccessful)" do
      expect(Open3).to receive(:capture3).with('termux-test', 'x', 'y', stdin_data: '').once.and_return(['', '', failure])
      expect { subject.api_command('test', nil, 'x', 'y') }.to raise_error(TermuxRubyApi::CommandError)
    end

    it "works with a command with standard input (successful)" do
      expect(Open3).to receive(:capture3).with('termux-test', stdin_data: 'input data').once.and_return(['', '', success])
      subject.api_command('test', 'input data')
    end

    it "works with a command with standard input (unsuccessful)" do
      expect(Open3).to receive(:capture3).with('termux-test', stdin_data: 'input data').once.and_return(['', '', failure])
      expect { subject.api_command('test', 'input data') }.to raise_error(TermuxRubyApi::CommandError)
    end

    it "works with a command with standard input and args (successful)" do
      expect(Open3).to receive(:capture3)
                         .with('termux-test', 'x', 'y', stdin_data: 'input data')
                         .once
                         .and_return(['', '', success])
      subject.api_command('test', 'input data', 'x', 'y')
    end

    it "works with a command with standard input and args (unsuccessful)" do
      expect(Open3).to receive(:capture3)
                         .with('termux-test', 'x', 'y', stdin_data: 'input data')
                         .once
                         .and_return(['', '', failure])
      expect { subject.api_command('test', 'input data', 'x', 'y') }.to raise_error(TermuxRubyApi::CommandError)
    end
  end

  describe "escaping arguments" do
    it "escapes special chars in arguments and command name" do
      expect(Open3).to receive(:capture3)
                         .with("termux-test\\&ls\\ -l",
                               "\\\"Hello\\ there\\\"\\ said\\ O\\'Donnell\\ \\(from\\ Smith\\&Smith\\)",
                               "\\&\\<\\|\\>\\!",
                               "\\`rm\\ -rf\\`",
                               stdin_data: '')
                         .once
                         .and_return(['', '', success])
      subject.api_command('test&ls -l', nil, '"Hello there" said O\'Donnell (from Smith&Smith)', '&<|>!', '`rm -rf`')
    end
  end

  describe "working with JSON" do
    let (:json_result) { '{ "code": 1, "name": "string", "values": [1,2,3] }' }

    it "works with a basic command" do
      expect(Open3).to receive(:capture3).with('termux-test', stdin_data: '').once.and_return([json_result, '', success])
      expect(subject.json_api_command('test')).to eq(code: 1, name: 'string', values: [1,2,3])
    end

    it "works with a command with args" do
      expect(Open3).to receive(:capture3).with('termux-test', 'x', 'y', stdin_data: '').once.and_return([json_result, '', success])
      expect(subject.json_api_command('test', nil, 'x', 'y')).to eq(code: 1, name: 'string', values: [1,2,3])
    end

    it "works with a command with standard input" do
      expect(Open3).to receive(:capture3).with('termux-test', stdin_data: 'input data').once.and_return([json_result, '', success])
      expect(subject.json_api_command('test', 'input data')).to eq(code: 1, name: 'string', values: [1,2,3])
    end

    it "works with a command with standard input and args" do
      expect(Open3).to receive(:capture3).with('termux-test', 'x', 'y', stdin_data: 'input data').once.and_return([json_result, '', success])
      expect(subject.json_api_command('test', 'input data', 'x', 'y')).to eq(code: 1, name: 'string', values: [1,2,3])
    end
  end
end
