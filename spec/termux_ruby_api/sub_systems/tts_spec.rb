require 'termux_ruby_api'

RSpec.describe TermuxRubyApi::SubSystems::Tts do
    
  before do
    @base = TermuxRubyApi::Base.new
  end

  it "speak works" do
    expect(@base).to receive(:api_command).with('tts-speak', 'Hello kids!!').once
    @base.tts.speak('Hello kids!!')
  end
end
