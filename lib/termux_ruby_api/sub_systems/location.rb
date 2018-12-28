module TermuxRubyApi
  module SubSystems
    class Location < Base
      def get(provider: nil, request: nil)
        args = []
        args += ['-p', provider] unless provider.nil?
        args += ['-r', request] unless request.nil?
        res = owner.json_api_command('location', nil, *args)
        TermuxRubyApi::Utils::Xformer.xform(res, provider: :symbol)
      end

      def gps(request: nil)
        get(provider: :gps, request: request)
      end

      def network(request: nil)
        get(provider: :network, request: request)
      end
    end
  end
end
