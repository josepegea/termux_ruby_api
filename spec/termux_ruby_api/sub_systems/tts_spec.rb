require 'termux_ruby_api'

RSpec.describe TermuxRubyApi::SubSystems::Tts do
    
  before do
    @base = TermuxRubyApi::Base.new
  end

  it "speak works" do
    expect(@base).to receive(:api_command).with('tts-speak', 'Hello kids!!').once
    @base.tts.speak('Hello kids!!')
  end

  it "speak accepts arguments" do
    expect(@base).to receive(:api_command)
                       .with('tts-speak',
                             'Hello kids!!',
                             '-e', 'google',
                             '-l', 'en',
                             '-n', 'en',
                             '-v', 'I',
                             '-p', '1',
                             '-r', '1',
                             '-s', 'NOTIFICATION'
                            ).once
    @base.tts.speak('Hello kids!!', engine: :google, language: :en, region: :en,
                    variant: 'I', pitch: 1, rate: 1, stream: 'NOTIFICATION')
  end

  let(:result) { <<EOT
[
  {
    "name": "com.google.android.tts",
    "label": "Google Text-to-speech Engine",
    "default": true
  }
]
EOT
  }

  it "lists the available engines" do
    expect(@base).to receive(:api_command).with('tts-engines', nil).and_return(result)
    res = @base.tts.engines
    expect(res.size).to eq(1)
    expect(res[0][:name]).to eq('com.google.android.tts')
    expect(res[0][:label]).to eq('Google Text-to-speech Engine')
    expect(res[0][:default]).to be(true)
  end
end
