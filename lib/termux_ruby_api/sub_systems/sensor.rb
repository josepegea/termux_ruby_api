module TermuxRubyApi
  module SubSystems
    class Sensor < Base
      # Produces continues updates of the selected sensors
      # If a block is passed, the results are yielded to the block as soon as they're ready
      # in the form of an array of hashes, where each element of the array corresponds to one
      # of the captured sensors.
      # If no block is passed, the IO object for the output string and the wait Thread
      # are returned. See {TermuxRubyApi::Base#json_streamed_api_command} for details.
      # @param delay [Fixnum] time in milliseconds to wait between updates
      # @param limit [Fixnum] number of updates. If nil, it sends updates forever
      # @param sensors [Array <String>] names of sensors to capture (as returned from #list)
      # @note If limit==nil this method never returns.
      #   In that case is normal to invoke it from inside a thread or
      #   a child process.
      def capture(delay: 1000, limit: nil, sensors:, &block)
        args = []
        args += ['-n', limit.to_s] unless limit.nil?
        args += ['-d', delay.to_s] unless delay.nil?
        args += ['-s', sensors.join(',')]
        if block_given?
          owner.json_streamed_api_command('sensor', nil, *args) do |json_result|
            yield json_result
          end
        else
          return owner.json_streamed_api_command('sensor', nil, *args)
        end
      end

      # Gets a single update of the selected sensors
      # If a block is passed, the results are yielded to the block as soon as they're ready
      # in the form of an array of hashes, where each element of the array corresponds to one
      # of the captured sensors.
      # If no block is passed, the array of hashes is returned.
      # @param sensors [String] names of sensors to capture (as returned from #list)
      def capture_once(*sensors, &block)
        data = nil
        capture(limit: 1, sensors: sensors) do |json_result|
          data = json_result
        end
        if block_given?
          yield data
        else
          return data
        end
      end

      # Returns the list of available sensors
      # @return [String]
      def list
        owner.json_api_command('sensor', nil, '-l')&.fetch(:sensors)
      end
    end
  end
end
