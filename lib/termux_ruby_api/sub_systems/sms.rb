module TermuxRubyApi
  module SubSystems
    class Sms < TermuxRubyApi::SubSystems::Base
      # Gets part of the list of SMS messages in the phone
      # @param limit [Fixnum] Number of messages to return
      # @param offset [Fixnum] Start from message
      # @param type [:inbox, :outbox, :sent]
      # @return [Array <Hash>]
      def list(limit: nil, offset: nil, type: nil)
        args = []
        args = owner.generate_args_list([['-l', limit&.to_s],
                                         ['-o', offset&.to_s],
                                         ['-t', type]
                                        ])
        res = owner.json_api_command('sms-list', nil, *args)
        TermuxRubyApi::Utils::Xformer.xform(res, received: :time, type: :symbol)
      end

      # Lists all the SMS messages in the phone, with no pagination
      # @param type [:inbox, :outbox, :sent]
      # @return (see #list)
      def list_all(type: nil)
        list(limit: -1, type: type)
      end

      # Lists the SMS messages in the inbox folder of the phone
      # @param limit [Fixnum] Number of messages to return
      # @param offset [Fixnum] Start from message
      # @return (see #list)
      def inbox(limit: nil, offset: nil)
        list(limit: limit, offset: offset, type: :inbox)
      end

      # Lists all the SMS messages in the inbox folder of the phone, with no pagination
      # @return (see #list)
      def inbox_all
        list_all(type: :inbox)
      end

      # Lists the SMS messages in the outbox folder of the phone
      # @param limit [Fixnum] Number of messages to return
      # @param offset [Fixnum] Start from message
      # @return (see #list)
      def outbox(limit: nil, offset: nil)
        list(limit: limit, offset: offset, type: :outbox)
      end

      # Lists all the SMS messages in the outbox folder of the phone, with no pagination
      # @return (see #list)
      def outbox_all
        list_all(type: :outbox)
      end

      # Lists the SMS messages in the sent folder of the phone
      # @param limit [Fixnum] Number of messages to return
      # @param offset [Fixnum] Start from message
      # @return (see #list)
      def sent(limit: nil, offset: nil)
        list(limit: limit, offset: offset, type: :sent)
      end

      # Lists all the SMS messages in the sent folder of the phone, with no pagination
      # @return (see #list)
      def sent_all
        list_all(type: :sent)
      end

      # Lists the SMS messages in the draft folder of the phone
      # @param limit [Fixnum] Number of messages to return
      # @param offset [Fixnum] Start from message
     # @return (see #list)
      def draft(limit: nil, offset: nil)
        list(limit: limit, offset: offset, type: :draft)
      end

      # Lists all the SMS messages in the draft folder of the phone, with no pagination
      # @return (see #list)
      def draft_all
        list_all(type: :draft)
      end

      # Sends an SMS message
      # @param msg [String] the text of the message
      # @param numbers [String] all subsequent params are interpreted as numbers to send the message to
      def send(msg, *numbers)
        args = owner.generate_args(["-n", "#{numbers.join(',')}"])
        owner.api_command('sms-send', msg, *args)
      end
    end
  end
end
