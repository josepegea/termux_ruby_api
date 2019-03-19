require 'termux_ruby_api'

RSpec.describe TermuxRubyApi::SubSystems::Dialog do

  before do
    @base = TermuxRubyApi::Base.new
  end

  it "text" do
    expect(@base).to receive(:json_api_command).with('dialog', nil, "text", "-t", "Title\ntext", "-i", "Hint text").once
    @base.dialog.text("Title\ntext", hint: "Hint text")
  end

  it "confirm" do
    expect(@base).to receive(:json_api_command).with('dialog', nil, "confirm", "-t", "Title\ntext", "-i", "Hint text").once
    @base.dialog.confirm("Title\ntext", hint: "Hint text")
  end

  it "checkbox" do
    expect(@base).to receive(:json_api_command).with('dialog', nil, "checkbox", "-t", "Title", "-v", "red,green,brown").once
    @base.dialog.checkbox("Title", options: %w(red green brown), result_type: :raw)
  end

  it "radio" do
    expect(@base).to receive(:json_api_command).with('dialog', nil, "radio", "-t", "Title", "-v", "red,green,brown").once
    @base.dialog.radio("Title", options: %w(red green brown))
  end

  it "spinner" do
    expect(@base).to receive(:json_api_command).with('dialog', nil, "spinner", "-t", "Title", "-v", "red,green,brown").once
    @base.dialog.spinner("Title", options: %w(red green brown))
  end

  it "sheet" do
    expect(@base).to receive(:json_api_command).with('dialog', nil, "sheet", "-t", "Title", "-v", "red,green,brown").once
    @base.dialog.sheet("Title", options: %w(red green brown))
  end

  it "date" do
    expect(@base).to receive(:json_api_command).with('dialog', nil, "date", "-t", "Title").once
    @base.dialog.date("Title")
  end

  it "speech" do
    expect(@base).to receive(:json_api_command).with('dialog', nil, "speech", "-t", "Title", "-i", "Hint").once
    @base.dialog.speech("Title", hint: "Hint")
  end

  describe "getting the results" do

    describe "single value" do

      before do
        expect(@base).to receive(:api_command).and_return(<<~JSON
                                                           {
                                                             "code": -1,
                                                             "text": "yellow",
                                                             "index": 2
                                                           }
                                                           JSON
                                                         )
      end

      it "works with raw" do
        expect(@base.dialog.radio(options: %w(red green yellow), result_type: :raw))
          .to eq({ code: -1, text: "yellow", index: 2 }.with_indifferent_access)
      end

      it "works with text" do
        expect(@base.dialog.radio(options: %w(red green yellow), result_type: :text)).to eq("yellow")
      end

      it "works with index" do
        expect(@base.dialog.radio(options: %w(red green yellow), result_type: :index)).to eq(2)
      end
    end

    describe "multiple values" do

      before do
        expect(@base).to receive(:api_command).and_return(<<~JSON
                                                           {
                                                             "code": -1,
                                                             "text": "[green, red]",
                                                             "values": [
                                                               {
                                                                 "index": 0,
                                                                 "text": "green"
                                                               },
                                                               {
                                                                 "index": 1,
                                                                 "text": "red"
                                                               }
                                                             ]
                                                           }
                                                           JSON
                                                         )
      end

      it "works with raw" do
        expect(@base.dialog.checkbox(options: %w(red green yellow), result_type: :raw))
          .to eq({
                   code: -1,
                   text: "[green, red]",
                   values: [
                     { index: 0, text: "green" },
                     { index: 1, text: "red" }
                   ]
                 }.with_indifferent_access)
      end

      it "works with text" do
        expect(@base.dialog.checkbox(options: %w(green red yellow), result_type: :text)).to eq(%w(green red))
      end

      it "works with index" do
        expect(@base.dialog.checkbox(options: %w(green red yellow), result_type: :index)).to eq([0, 1])
      end
    end

    describe "boolean value" do
      it "works with true" do
        expect(@base).to receive(:api_command).and_return('{ "code": 0, "text": "yes" }')
        expect(@base.dialog.confirm(result_type: :boolean)).to be true
      end

      it "works with false" do
        expect(@base).to receive(:api_command).and_return('{ "code": 0, "text": "no" }')
        expect(@base.dialog.confirm(result_type: :boolean)).to be false
      end

      it "works with cancel" do
        expect(@base).to receive(:api_command).and_return('{ "code": -1 }')
        expect(@base.dialog.confirm(result_type: :boolean)).to be false
      end
    end

    describe "date value" do
      it "works with a date" do
        expect(@base).to receive(:api_command).and_return('{ "code": -1, "text": "Fri Mar 15 00:00:00 GMT+01:00 2019" }')
        expect(@base.dialog.date(result_type: :date)).to eq(Date.parse("Fri Mar 15 00:00:00 GMT+01:00 2019"))
      end

      it "works with cancel" do
        expect(@base).to receive(:api_command).and_return('{ "code": -2, "text": "" }')
        expect(@base.dialog.date(result_type: :date)).to be nil
      end
    end
  end
end
