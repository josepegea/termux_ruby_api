module TermuxRubyApi
  module SubSystems
    class Location < Base
      # Returns the current location
      # @param provider [:gps, :network, :passive]
      #   :gps #=> Use GPS
      #   :network #=> Use mobile or Wifi network
      #   :passive #=> Use a low battery method
      # @param request [:once, :last, :updates]
      #   :once #=> Return after the location is obtained
      #   :last #=> Return the last obtained location
      #   :updates #=> Send repeated updates as location is updated. Doesn't work in current version.
      # @return [Hash]
      def get(provider: nil, request: nil)
        args = owner.generate_args_list([['-p', provider],
                                         ['-r', request]
                                        ])
        res = owner.json_api_command('location', nil, *args)
        TermuxRubyApi::Utils::Xformer.xform(res, provider: :symbol)
      end

      # Returns the current location, using GPS
      # @param request (see #get)
      # @return (see #get)
      def gps(request: nil)
        get(provider: :gps, request: request)
      end

      # Returns the current location, using Mobile/Wifi network
      # @param request (see #get)
      # @return (see #get)
      def network(request: nil)
        get(provider: :network, request: request)
      end
    end
  end
end
