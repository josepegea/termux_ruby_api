module TermuxRubyApi
  module SubSystems
    class Sensor < Base
      def capture(delay: 1000, limit: nil, sensors:, &block)
        args = []
        args += ['-n', limit.to_s] unless limit.nil?
        args += ['-d', delay.to_s] unless delay.nil?
        args += ['-s', sensors.join(',')]
        owner.json_streamed_api_command('sensor', nil, *args) do |json_result|
          yield json_result
        end
      end
    end
  end
end
