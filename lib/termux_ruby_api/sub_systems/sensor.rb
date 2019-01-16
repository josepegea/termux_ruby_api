module TermuxRubyApi
  module SubSystems
    class Sensor < Base
      def capture(&block)
        owner.json_streamed_api_command('sensor') do |json_result|
          block.yield json_result
        end
      end
    end
  end
end
