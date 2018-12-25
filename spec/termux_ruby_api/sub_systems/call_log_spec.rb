require 'termux_ruby_api'

RSpec.describe TermuxRubyApi::SubSystems::CallLog do

  let (:result) { <<EOT
[
  {
    "name": "Sales call",
    "phone_number": "123456789",
    "type": "INCOMING",
    "date": "2018-12-17 05:35:31",
    "duration": "04:30"
  },
  {
    "name": "Missed call",
    "phone_number": "Unknown",
    "type": "INCOMING",
    "date": "2018-12-17 12:13:31",
    "duration": "00:00"
  },
  {
    "name": "Mom",
    "phone_number": "987654321",
    "type": "OUTGOING",
    "date": "2018-12-18 24:16:13",  // Termux like times starting with hour 24 !!!
    "duration": "02:27"
  }
]
EOT
  }
    
  before do
    @base = TermuxRubyApi::Base.new
  end

  it "works without arguments" do
    expect(@base).to receive(:`).with('termux-call-log').once.and_return(result)
    @base.call_log.log
  end

  it "sends 'limit' argument" do
    expect(@base).to receive(:`).with('termux-call-log -l 2').once.and_return(result)
    @base.call_log.log(limit: 2)
  end

  it "sends 'offset' argument" do
    expect(@base).to receive(:`).with('termux-call-log -o 1').once.and_return(result)
    @base.call_log.log(offset: 1)
  end

  it "sends both arguments" do
    expect(@base).to receive(:`).with('termux-call-log -l 2 -o 1').once.and_return(result)
    @base.call_log.log(offset: 1, limit: 2)
  end

  it "works with log_all" do
    expect(@base).to receive(:`).with('termux-call-log -l -1').once.and_return(result)
    @base.call_log.log_all
  end

  it "parses the resulting JSON" do
    expect(@base).to receive(:`).and_return(result)
    res = @base.call_log.log
    expect(res.size).to eq(3)
    expect(res.map(&:keys).flatten.uniq).to match_array(%i(name phone_number type date duration))
    expect(res.map { |r| r[:type] }).to match_array(%i(INCOMING INCOMING OUTGOING))
    expect(res.map { |r| r[:duration] }).to match_array([270, 0, 147])
    times = ['2018-12-17 05:35:31', '2018-12-17 12:13:31', '2018-12-18 00:16:13'].map { |s| Time.parse(s) }
    expect(res.map { |r| r[:date] }).to match_array(times)
  end
end
