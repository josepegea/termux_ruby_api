require 'termux_ruby_api'

RSpec.describe TermuxRubyApi::SubSystems::Sms do

  let (:result) { <<EOT
[
  {
    "threadid": 14,
    "type": "inbox",
    "read": true,
    "sender": "Mum&Dad",
    "number": "+00123456789",
    "received": "2018-12-07 18:11",
    "body": "Don't forget to have breakfast!!"
  },
  {
    "threadid": 51,
    "type": "inbox",
    "read": false,
    "sender": "Spammer",
    "number": "987654321",
    "received": "2018-12-09 16:25",
    "body": "Missing you! We've got new offers"
  },
  {
    "threadid": 51,
    "type": "inbox",
    "read": false,
    "sender": "Unknown",
    "number": "Unknown",
    "received": "2018-12-10 24:25", // Termux likes the hour '24'
    "body": "Answer our calls!!"
  }
]
EOT
  }
    
  before do
    @base = TermuxRubyApi::Base.new
  end

  it "works without arguments" do
    expect(@base).to receive(:api_command).with('sms-list', nil).once.and_return(result)
    @base.sms.list
  end

  it "sends 'limit' argument" do
    expect(@base).to receive(:api_command).with('sms-list', nil, '-l', '2').once.and_return(result)
    @base.sms.list(limit: 2)
  end

  it "sends 'offset' argument" do
    expect(@base).to receive(:api_command).with('sms-list', nil, '-o', '1').once.and_return(result)
    @base.sms.list(offset: 1)
  end

  it "sends 'type' argument" do
    expect(@base).to receive(:api_command).with('sms-list', nil, '-t', :inbox).twice.and_return(result)
    @base.sms.list(type: :inbox)
    @base.sms.inbox
    expect(@base).to receive(:api_command).with('sms-list', nil, '-t', :sent).twice.and_return(result)
    @base.sms.list(type: :sent)
    @base.sms.sent
    expect(@base).to receive(:api_command).with('sms-list', nil, '-t', :outbox).twice.and_return(result)
    @base.sms.list(type: :outbox)
    @base.sms.outbox
    expect(@base).to receive(:api_command).with('sms-list', nil, '-t', :draft).twice.and_return(result)
    @base.sms.list(type: :draft)
    @base.sms.draft
  end

  it "combines arguments" do
    expect(@base).to receive(:api_command).with('sms-list', nil, '-l', '2', '-o', '1').once.and_return(result)
    @base.sms.list(offset: 1, limit: 2)
    expect(@base).to receive(:api_command).with('sms-list', nil, '-l', '2', '-o', '1', '-t', :inbox).twice.and_return(result)
    @base.sms.list(offset: 1, limit: 2, type: :inbox)
    @base.sms.inbox(offset: 1, limit: 2)
    expect(@base).to receive(:api_command).with('sms-list', nil, '-l', '2', '-o', '1', '-t', :outbox).twice.and_return(result)
    @base.sms.list(offset: 1, limit: 2, type: :outbox)
    @base.sms.outbox(offset: 1, limit: 2)
    expect(@base).to receive(:api_command).with('sms-list', nil, '-l', '2', '-o', '1', '-t', :draft).twice.and_return(result)
    @base.sms.list(offset: 1, limit: 2, type: :draft)
    @base.sms.draft(offset: 1, limit: 2)
  end

  it "works with '_all'" do
    expect(@base).to receive(:api_command).with('sms-list', nil, '-l', '-1').once.and_return(result)
    @base.sms.list_all
    expect(@base).to receive(:api_command).with('sms-list', nil, '-l', '-1', '-t', :inbox).once.and_return(result)
    @base.sms.inbox_all
    expect(@base).to receive(:api_command).with('sms-list', nil, '-l', '-1', '-t', :outbox).once.and_return(result)
    @base.sms.outbox_all
    expect(@base).to receive(:api_command).with('sms-list', nil, '-l', '-1', '-t', :sent).once.and_return(result)
    @base.sms.sent_all
    expect(@base).to receive(:api_command).with('sms-list', nil, '-l', '-1', '-t', :draft).once.and_return(result)
    @base.sms.draft_all
  end

  it "parses the resulting JSON" do
    expect(@base).to receive(:api_command).and_return(result)
    res = @base.sms.list
    expect(res.size).to eq(3)
    expect(res.map(&:keys).flatten.uniq).to match_array(%i(threadid type read sender number received body))
    expect(res.map { |r| r[:type] }).to match_array(%i(inbox inbox inbox))
    times = ['2018-12-07 18:11', '2018-12-09 16:25', '2018-12-10 00:25'].map { |s| Time.parse(s) }
    expect(res.map { |r| r[:received] }).to match_array(times)
  end

  describe "Sending..." do
    it "Sends with a single phone number" do
      expect(@base).to receive(:api_command).with('sms-send', 'Hello world!!', '-n', '123456789').once.and_return(result)
      @base.sms.send('Hello world!!', 123456789)
    end

    it "Sends with a several phone numbers" do
      expect(@base).to receive(:api_command).with('sms-send', 'Hello world!!', '-n', '123456789,987654321').once.and_return(result)
      @base.sms.send('Hello world!!', 123456789, 987654321)
    end
  end
end
