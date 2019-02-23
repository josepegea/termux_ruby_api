module TermuxRubyApi
  module SubSystems
    class Sms < Base
      def list(limit: nil, offset: nil, type: nil)
        args = []
        args = owner.generate_args_list([['-l', limit&.to_s],
                                         ['-o', offset&.to_s],
                                         ['-t', type]
                                        ])
        res = owner.json_api_command('sms-list', nil, *args)
        TermuxRubyApi::Utils::Xformer.xform(res, received: :time, type: :symbol)
      end

      def list_all(type: nil)
        list(limit: -1, type: type)
      end

      def inbox(limit: nil, offset: nil)
        list(limit: limit, offset: offset, type: :inbox)
      end

      def inbox_all
        list_all(type: :inbox)
      end

      def outbox(limit: nil, offset: nil)
        list(limit: limit, offset: offset, type: :outbox)
      end

      def outbox_all
        list_all(type: :outbox)
      end

      def sent(limit: nil, offset: nil)
        list(limit: limit, offset: offset, type: :sent)
      end

      def sent_all
        list_all(type: :sent)
      end

      def draft(limit: nil, offset: nil)
        list(limit: limit, offset: offset, type: :draft)
      end

      def draft_all
        list_all(type: :draft)
      end

      def send(msg, *numbers)
        args = owner.generate_args(["-n", "#{numbers.join(',')}"])
        owner.api_command('sms-send', msg, *args)
      end
    end
  end
end
