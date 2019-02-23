module TermuxRubyApi
  module SubSystems
    class CallLog < Base
      def log(limit:nil, offset:nil)
        args = owner.generate_args_list([['-l', limit&.to_s],
                                         ['-o', offset&.to_s]
                                        ])
        res = owner.json_api_command('call-log', nil, *args)
        TermuxRubyApi::Utils::Xformer.xform(res, date: :time, duration: :duration, type: :symbol)
      end

      def log_all
        log(limit: -1)
      end
    end
  end
end
