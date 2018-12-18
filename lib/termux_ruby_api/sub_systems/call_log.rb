module TermuxRubyApi
  module SubSystems
    class CallLog < Base
      def log(limit:nil, offset:nil)
        args = []
        args += ['-l', limit.to_s] unless limit.nil?
        args += ['-o', offset.to_s] unless offset.nil?
        res = owner.json_api_command('call-log', *args)
        TermuxRubyApi::Utils::Xformer.xform(res, date: :time, duration: :duration, type: :symbol)
      end
    end
  end
end
