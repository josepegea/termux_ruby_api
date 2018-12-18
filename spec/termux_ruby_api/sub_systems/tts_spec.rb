require 'termux_ruby_api'

RSpec.describe TermuxRubyApi::SubSystems::Tts do
    
  before do
    @base = TermuxRubyApi::Base.new
  end

  it "speak works" do
    expect(@base).to receive(:`).with('termux-tts-speak Hello').once
    @base.tts.speak('Hello')
  end

  it "set works with special chars" do
    expect(@base).to receive(:`).with('termux-tts-speak \"Hello\ there\"\ said\ O\\\'Donell\ \(from\ Smith\&Smith\ \<\|\>\)').once
    @base.tts.speak('"Hello there" said O\'Donell (from Smith&Smith <|>)')
  end
end
