require 'termux_ruby_api'

RSpec.describe TermuxRubyApi::SubSystems::Clipboard do
    
  before do
    @base = TermuxRubyApi::Base.new
  end

  it "get works" do
    expect(@base).to receive(:api_command).with('clipboard-get').once
    @base.clipboard.get
  end

  it "set works" do
    expect(@base).to receive(:api_command).with('clipboard-set', "Hello\nthere!").once
    @base.clipboard.set("Hello\nthere!")
  end
end
