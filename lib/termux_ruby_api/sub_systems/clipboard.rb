module TermuxRubyApi
  module SubSystems
    class Clipboard < TermuxRubyApi::SubSystems::Base
      # Stores `value` in the Android system clipboard
      # @param value [String]
      def set(value)
        owner.api_command('clipboard-set', value)
      end

      # Gets the contents of the Android system clipboard
      # @return value [String]
      def get
        owner.api_command('clipboard-get')
      end
    end
  end
end
