module TermuxRubyApi
  module SubSystems
    class CallLog < Base
      # Gets part of the list of phone calls in the phone
      # @param limit [Fixnum] Number of messages to return
      # @param offset [Fixnum] Start from message
      # @return [Array <Hash>]
      def log(limit:nil, offset:nil)
        args = owner.generate_args_list([['-l', limit&.to_s],
                                         ['-o', offset&.to_s]
                                        ])
        res = owner.json_api_command('call-log', nil, *args)
        TermuxRubyApi::Utils::Xformer.xform(res, date: :time, duration: :duration, type: :symbol)
      end

      # Gets the whole list of phone calls in the phone, with no pagination
      # @return (see #log)
      def log_all
        log(limit: -1)
      end
    end
  end
end
