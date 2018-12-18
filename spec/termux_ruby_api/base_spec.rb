require 'termux_ruby_api/base'

RSpec.describe TermuxRubyApi::Base do

  it "sends a basic command" do
    expect(subject).to receive(:`).with('termux-test')
    subject.api_command('test')
  end

  it "sends a basic command with args" do
    expect(subject).to receive(:`).with('termux-test x y')
    subject.api_command('test', 'x', 'y')
  end

  it "parses a JSON command" do
    expect(subject).to receive(:`).with('termux-test').and_return('{ "code": 1, "name": "string", "values": [1,2,3] }')
    expect(subject.json_api_command('test')).to eq(code: 1, name: 'string', values: [1,2,3])
  end
end
