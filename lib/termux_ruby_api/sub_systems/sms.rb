module TermuxRubyApi
  module SubSystems
    class Sms < Base
      def list(limit: nil, offset: nil, type: nil)
        args = []
        args += ['-l', limit.to_s] unless limit.nil?
        args += ['-o', offset.to_s] unless offset.nil?
        args += ['-t', type.to_s] unless type.nil?
        res = owner.json_api_command('sms-list', *args)
        TermuxRubyApi::Utils::Xformer.xform(res, received: :time, type: :symbol)
      end

      def inbox(limit: nil, offset: nil)
        list(limit: limit, offset: offset, type: :inbox)
      end

      def outbox(limit: nil, offset: nil)
        list(limit: limit, offset: offset, type: :outbox)
      end

      def sent(limit: nil, offset: nil)
        list(limit: limit, offset: offset, type: :sent)
      end

      def draft(limit: nil, offset: nil)
        list(limit: limit, offset: offset, type: :draft)
      end
    end
  end
end
