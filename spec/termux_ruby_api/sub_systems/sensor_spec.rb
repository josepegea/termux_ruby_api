require 'termux_ruby_api'

RSpec.describe TermuxRubyApi::SubSystems::Sensor do

  let (:sensor_list) { '{ "sensors": ["Step Counter", "Fake Sensor"] }' }

  let (:sensor_data) {
    {
      :"Step Counter" => {
        values: [23456]
      },
     :"Fake Sensor" => {
        field1: 3,
        field2: "string",
        field3: [1, 2, 3]
      }
    }
  }

  before do
    @base = TermuxRubyApi::Base.new
  end

  it "gets the sensor list" do
    expect(@base).to receive(:api_command).with('sensor', nil, '-l')
                       .once
                       .and_return(sensor_list)
    expect(@base.sensor.list).to match_array(["Step Counter", "Fake Sensor"])
  end

  it "gets data once, without a block" do
    expect(@base).to receive(:json_streamed_api_command)
                       .with('sensor', nil, '-n', '1', '-d', '1000', '-s',
                             "Step Counter,Fake Sensor")
                       .once
                       .and_yield(sensor_data)
    expect(@base.sensor.capture_once("Step Counter", "Fake Sensor")).to eq(sensor_data)
  end

  it "gets data once, with a block" do
    expect(@base).to receive(:json_streamed_api_command)
                       .with('sensor', nil, '-n', '1', '-d', '1000', '-s',
                             "Step Counter,Fake Sensor")
                       .once
                       .and_yield(sensor_data)
    expect { |b| @base.sensor.capture_once("Step Counter", "Fake Sensor", &b) }.to yield_successive_args(sensor_data)
  end

  it "gets all the arguments for capture" do
    expect(@base).to receive(:json_streamed_api_command)
                       .with('sensor', nil, '-n', '4', '-d', '100', '-s',
                             "Step Counter,Fake Sensor")
                       .once
    @base.sensor.capture(sensors: ["Step Counter", "Fake Sensor"],
                         limit: 4,
                         delay: 100)
  end

  it "gets streamed data, with a block" do
    expect(@base).to receive(:json_streamed_api_command)
                       .with('sensor', nil, '-d', '1000', '-s',
                             "Step Counter,Fake Sensor")
                       .once
                       .and_yield(sensor_data)
                       .and_yield(sensor_data)
                       .and_yield(sensor_data)
    expect { |b| @base.sensor.capture(sensors: ["Step Counter", "Fake Sensor"], &b) }.to yield_successive_args(sensor_data,
                                                                                                               sensor_data,
                                                                                                               sensor_data)
  end
end
