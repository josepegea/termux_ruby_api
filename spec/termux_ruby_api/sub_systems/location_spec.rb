require 'termux_ruby_api'

RSpec.describe TermuxRubyApi::SubSystems::Location do

  let (:result) { <<EOT
{
  "latitude": 40.4043461,
  "longitude": -3.878738,
  "altitude": 0.0,
  "accuracy": 18.66699981689453,
  "bearing": 0.0,
  "speed": 0.0,
  "elapsedMs": 1,
  "provider": "network"
}
EOT
  }
    
  before do
    @base = TermuxRubyApi::Base.new
  end

  it "works without arguments" do
    expect(@base).to receive(:api_command).with('location', nil).once.and_return(result)
    @base.location.get
  end

  it "sends 'provider' argument (general and shorthands)" do
    expect(@base).to receive(:api_command).with('location', nil, '-p', :gps).twice.and_return(result)
    @base.location.get(provider: :gps)
    @base.location.gps
    expect(@base).to receive(:api_command).with('location', nil, '-p', :network).twice.and_return(result)
    @base.location.get(provider: :network)
    @base.location.network
  end

  it "sends 'request' argument" do
    expect(@base).to receive(:api_command).with('location', nil, '-r', :once).once.and_return(result)
    @base.location.get(request: :once)
  end

  it "sends both arguments" do
    expect(@base).to receive(:api_command).with('location', nil, '-p', :gps, '-r', :once).twice.and_return(result)
    @base.location.get(request: :once, provider: :gps)
    @base.location.gps(request: :once)
    expect(@base).to receive(:api_command).with('location', nil, '-p', :network, '-r', :once).once.and_return(result)
    @base.location.network(request: :once)
  end

  it "parses the resulting JSON" do
    expect(@base).to receive(:api_command).and_return(result)
    res = @base.location.get
    expect(res[:provider]).to eq(:network)
  end
end
