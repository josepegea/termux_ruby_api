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
    it "escapes special chars in command name but not in args" do
      expect(Open3).to receive(:capture3)
                         .with("termux-test\\&\\&rm\\ -rf",
                               '"Hello there" said O\'Donnell',
                               stdin_data: '')
                         .once
                         .and_return(['', '', success])
      subject.api_command('test&&rm -rf', nil, '"Hello there" said O\'Donnell')
    end
  end

  describe "working with JSON" do
    let (:json_result) { '{ "code": 1, "name": "string", "values": [1,2,3] }' }

    it "works with a basic command" do
      expect(Open3).to receive(:capture3).with('termux-test', stdin_data: '').once.and_return([json_result, '', success])
      expect(subject.json_api_command('test')).to eq({ code: 1, name: 'string', values: [1,2,3] }.with_indifferent_access)
    end

    it "works with a command with args" do
      expect(Open3).to receive(:capture3).with('termux-test', 'x', 'y', stdin_data: '').once.and_return([json_result, '', success])
      expect(subject.json_api_command('test', nil, 'x', 'y')).to eq({ code: 1, name: 'string', values: [1,2,3] }.with_indifferent_access)
    end

    it "works with a command with standard input" do
      expect(Open3).to receive(:capture3).with('termux-test', stdin_data: 'input data').once.and_return([json_result, '', success])
      expect(subject.json_api_command('test', 'input data')).to eq({ code: 1, name: 'string', values: [1,2,3] }.with_indifferent_access)
    end

    it "works with a command with standard input and args" do
      expect(Open3).to receive(:capture3).with('termux-test', 'x', 'y', stdin_data: 'input data').once.and_return([json_result, '', success])
      expect(subject.json_api_command('test', 'input data', 'x', 'y')).to eq({ code: 1, name: 'string', values: [1,2,3] }.with_indifferent_access)
    end
  end

  describe "streamed command" do
    it "passes the streamed results to a block with no stdin data" do
      i = double("stdin")
      o = double("stdout")
      t = double("wait_thread")
      tv = double("thread_value")
      expect(i).to receive(:close).once
      expect(o).to receive(:each_line).once.and_yield("line 1").and_yield("line 2")
      expect(o).to receive(:close).once
      expect(t).to receive(:value).once.and_return(tv)
      expect(tv).to receive(:success?).once.and_return(true)
      expect(Open3).to receive(:popen2).with('termux-test', 'x', 'y').once.and_return([i, o, t])
      expect { |b| subject.streamed_api_command('test', nil, 'x', 'y', &b) }.to yield_successive_args("line 1", "line 2")
    end

    it "passes the streamed results to a block with stdin data" do
      i = double("stdin")
      o = double("stdout")
      t = double("wait_thread")
      tv = double("thread_value")
      expect(i).to receive(:puts).once.with("Input data")
      expect(i).to receive(:close).once
      expect(o).to receive(:each_line).once.and_yield("line 1").and_yield("line 2")
      expect(o).to receive(:close).once
      expect(t).to receive(:value).once.and_return(tv)
      expect(tv).to receive(:success?).once.and_return(true)
      expect(Open3).to receive(:popen2).with('termux-test', 'x', 'y').once.and_return([i, o, t])
      expect { |b| subject.streamed_api_command('test', "Input data", 'x', 'y', &b) }.to yield_successive_args("line 1", "line 2")
    end
  end

  describe "JSON streamed command" do

    JSON_PAYLOAD = <<~JSON
      {
       "a": 1,
       "b": [
         2,
         3
       ],
       "c": {
         "d": "string"
       }
     }
     {
       "x": [
         {
           "a": 3,
           "b": [
             1,
             2
           ]
         },
         {
           "a": null,
           "b": "nothing"
         }
       ],
       "y": 23,
       "z": {
         "key": "value"
       }
     }
   JSON
    it "passes the streamed JSON to a block" do
      i = double("stdin")
      o = double("stdout")
      t = double("wait_thread")
      tv = double("thread_value")
      expect(i).to receive(:close).once
      out_double = expect(o).to receive(:each_line).once
      JSON_PAYLOAD.each_line do |l|
        out_double.and_yield(l)
      end
      expect(o).to receive(:close).once
      expect(t).to receive(:value).once.and_return(tv)
      expect(tv).to receive(:success?).once.and_return(true)
      expect(Open3).to receive(:popen2).with('termux-test', 'x', 'y').once.and_return([i, o, t])
      expect { |b| subject.json_streamed_api_command('test', nil, 'x', 'y', &b) }
        .to yield_successive_args(
              {
                a: 1,
                b: [2, 3],
                c: { d: "string" }
              },
              {
                x: [
                  { a: 3,
                    b: [1, 2]
                  },
                  { a: nil,
                    b: "nothing"
                  }
                ],
                y: 23,
                z: { key: "value" }
              }
            )
    end
  end
end

