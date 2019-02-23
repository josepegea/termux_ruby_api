module TermuxRubyApi
  module SubSystems
    class Location < Base
      def get(provider: nil, request: nil)
        args = owner.generate_args_list([['-p', provider],
                                         ['-r', request]
                                        ])
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
