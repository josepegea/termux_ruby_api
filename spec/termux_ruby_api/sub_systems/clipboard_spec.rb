require 'termux_ruby_api'

RSpec.describe TermuxRubyApi::SubSystems::Clipboard do
    
  before do
    @base = TermuxRubyApi::Base.new
  end

  it "get works" do
    expect(@base).to receive(:`).with('termux-clipboard-get').once
    @base.clipboard.get
  end

  it "set works" do
    expect(@base).to receive(:`).with('termux-clipboard-set Hello').once
    @base.clipboard.set('Hello')
  end

  it "set works with special chars" do
    expect(@base).to receive(:`).with('termux-clipboard-set \"Hello\ there\"\ said\ O\\\'Donell\ \(from\ Smith\&Smith\ \<\|\>\)').once
    @base.clipboard.set('"Hello there" said O\'Donell (from Smith&Smith <|>)')
  end
end
